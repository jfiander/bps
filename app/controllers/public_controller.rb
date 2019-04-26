# frozen_string_literal: true

class PublicController < ApplicationController
  include Public::Bilge
  include CalendarHelper

  before_action :list_bilges,             only: %i[newsletter bilge]
  before_action :registration_attributes, only: %i[register]
  before_action :find_event,              only: %i[register]
  before_action :find_registration,       only: %i[register]
  before_action :block_registration,      only: %i[register], if: :block_registration?

  title!('The Bilge Chatter', only: :newsletter)
  title!("Ship's Store", only: :store)
  title!('Calendar', only: :calendar)

  render_markdown_views

  def register
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
      @registration_attributes = { event_id: @event_id, email: clean_params[:email] }
    end
  end

  def find_event
    @event = Event.find_by(id: @event_id)
  end

  def find_registration
    @registration = Registration.find_by(@registration_attributes.slice(:event_id, :email))
    @registration ||= Registration.new(@registration_attributes)
  end

  def block_registration
    redirect_to send("#{@event.category}s_path", id: @event.id)
  end

  def block_registration?
    return false if @event.allow_public_registrations && @event.registerable?

    pub = @event.registerable? ? ' public' : ''
    flash[:alert] = "This course is not currently accepting#{pub} registrations."
    true
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
    if @registration.persisted?
      registration_existed
    elsif @registration.save
      registration_saved
    else
      registration_problem
    end
  end

  def registration_existed
    flash[:alert] = 'You are already registered for this course.'
    redirect_to send("show_#{register_event_type}_path", id: @event_id)
  end

  def registration_saved
    flash[:success] = 'You have successfully registered!'
    if @registration.payable?
      redirect_to ask_to_pay_path(model: 'registration', id: @registration.payment.token)
    else
      redirect_to send("show_#{register_event_type}_path", id: @event_id)
    end
  end

  def registration_problem
    flash[:alert] = 'We are unable to register you at this time.'
    redirect_to send("show_#{register_event_type}_path", id: @event_id)
  end

  def register_event_type
    event_type = @event.category
    event_type = 'event' if event_type == 'meeting'
    event_type
  end
end
