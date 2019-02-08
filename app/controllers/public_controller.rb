# frozen_string_literal: true

class PublicController < ApplicationController
  include Public::Bilge
  include CalendarHelper

  before_action :block_if_paid,           only: %i[register]
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
      format.js { @registration.persisted? ? already_registered_js : register_js }
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
    @registration = Registration.register(
      event_id: @registration_attributes[:event_id], email: @registration_attributes[:email]
    )
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

  def block_if_paid
    reg = Registration.with_users.find_by(user_registrations: { email: clean_params[:email] })
    return unless reg&.paid?

    flash[:alert] = 'That has already been paid for.'
    category_path = send("#{reg.event.category}s_path")
    render js: "window.location='#{category_path}'"
  end

  def register_js
    if @registration.save
      flash[:success] = 'You have successfully registered!'

      return require_payment if @event.advance_payment

      modal(header: 'You are now registered!') do
        render_to_string partial: 'events/modals/registered'
      end
    else
      flash[:alert] = 'We are unable to register you at this time.'
      render status: :unprocessable_entity
    end
  end

  def already_registered_js
    modal(header: 'You are already registered!') do
      render_to_string partial: 'events/modals/registered'
    end
  end

  def register_html
    if @registration.save
      registration_saved
    else
      registration_problem
    end
  end

  def require_payment
    # prepare_advance_payment

    modal(header: 'Advance Payment Required', status: :payment_required) do
      render_to_string partial: 'events/modals/registered'
    end
  end

  # def prepare_advance_payment
  #   reg_and_token_for_advance
  #   @client_token = Payment.client_token(user_id: current_user&.id)
  #   @transaction_amount = @event.cost
  #   @purchase_info = reg_purchase_info
  # end

  # def reg_and_token_for_advance
  #   @token ||= @registration&.payment&.token || payment_params[:token]
  #   @registration ||= Payment.find_by(token: @token).parent
  #   @event ||= @registration.event
  # end

  # def reg_purchase_info
  #   {
  #     name: @event.display_title, type: @event.category,
  #     date: @event.start_at.strftime(ApplicationController::PUBLIC_DATE_FORMAT),
  #     time: @event.start_at.strftime(ApplicationController::PUBLIC_TIME_FORMAT)
  #   }
  # end

  def registration_saved
    flash[:success] = 'You have successfully registered!'
    if @registration.payable?
      redirect_to ask_to_pay_path(token: @registration.payment.token)
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
