# frozen_string_literal: true

class PublicController < ApplicationController
  include PublicMethods
  include CalendarHelper

  skip_before_action :prerender_for_layout, only: [:register]

  before_action :list_bilges, only: %i[newsletter get_bilge]
  before_action :registration_attributes, only: [:register]
  before_action :find_event,              only: [:register]
  before_action :find_registration,       only: [:register]

  before_action only: [:bridge] { page_title('Bridge Officers') }
  before_action only: [:newsletter] { page_title('The Bilge Chatter') }
  before_action only: [:store] { page_title("Ship's Store") }
  before_action only: [:calendar] { page_title('Calendar') }

  render_markdown_views

  def register
    unless allow_registration?
      category = Event.find_by(id: register_params[:event_id]).category
      redirect_to send("#{category}s_path", id: register_params[:event_id])
      return
    end

    respond_to do |format|
      format.js { register_js }
      format.html { register_html }
    end
  end

  private

  def clean_params
    params.permit(:year, :month, :email, :event_id)
  end

  def register_params
    params.require(:registration).permit(:event_id, :name, :email, :phone)
  end

  def registration_attributes
    if params.key?(:registration)
      @event_id = register_params[:event_id]
      @registration_attributes = register_params.to_hash.symbolize_keys
    else
      @event_id = clean_params[:event_id]
      @registration_attributes = {
        event_id: @event_id,
        email: clean_params[:email]
      }
    end
  end

  def find_event
    @event = Event.find_by(id: @event_id)
  end

  def find_registration
    @registration = Registration.find_by(@registration_attributes.slice(:event_id, :email))
    @registration ||= Registration.new(@registration_attributes)
  end

  def allow_registration?
    return true if @event.allow_public_registrations && @event.registerable?

    pub = @event.registerable? ? ' public' : ''
    flash[:alert] = 'This course is not currently accepting' +
                    pub +
                    ' registrations.'
    false
  end

  def register_js
    if @registration.persisted?
      flash[:alert] = 'You are already registered for this course.'
      render status: :unprocessable_entity
    elsif @registration.save
      flash[:success] = 'You have successfully registered!'
    else
      flash[:alert] = 'We are unable to register you at this time.'
      render status: :unprocessable_entity
    end
  end

  def register_html
    event_type = @event.category
    event_type = :event if event_type == :meeting

    if @registration.persisted?
      flash[:alert] = 'You are already registered for this course.'
    elsif @registration.save
      flash[:success] = 'You have successfully registered!'
    else
      flash[:alert] = 'We are unable to register you at this time.'
    end
    redirect_to send("show_#{event_type}_path", id: @event_id)
  end
end
