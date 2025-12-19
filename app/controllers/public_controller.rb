# frozen_string_literal: true

class PublicController < ApplicationController
  include Application::RateLimit
  include Public::Bilge
  include Public::Announcements
  include Public::Donations
  include CalendarHelper

  before_action :list_bilges,             only: %i[newsletter bilge]
  before_action :registration_attributes, only: %i[register]
  before_action :find_event,              only: %i[register]
  before_action :find_registration,       only: %i[register]
  before_action :block_registration,      only: %i[register], if: :block_registration?
  before_action :block_url_data!,         only: %i[register]

  rate_limit!(:public_registrations, only: :register)

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
    set_glyc_pricing
    @registration
  end

  def set_glyc_pricing
    return unless @registration.event.location&.name == 'Great Lakes Yacht Club'
    return if @registration.event.member_cost.nil?
    return unless GLYCMember.find_by(email: registration_attributes[:email])

    @registration.override_cost = @registration.event.member_cost
    @registration.override_comment = 'GLYC Member'
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
      flash[:alert] = 'You are already registered.'
      render status: :unprocessable_entity
    elsif verify_recaptcha(model: @registration) && @registration.save
      flash[:success] = 'You have successfully registered!'
      send_registered_emails
    else
      flash[:alert] = 'We are unable to register you at this time.'
      render status: :unprocessable_entity
    end
  end

  def register_html
    if @registration.persisted?
      registration_existed
    elsif verify_recaptcha(model: @registration) && @registration.save
      registration_saved
    else
      registration_problem
    end
  end

  def registration_existed
    flash[:alert] = 'You are already registered.'
    send_registered_emails
    redirect_to send("show_#{register_event_type}_path", id: @event_id)
  end

  def registration_saved
    flash[:success] = 'You have successfully registered!'
    send_registered_emails
    save_registration_options if @registration.event.event_selections.any?
    if @registration.payable?
      redirect_to ask_to_pay_path(token: @registration.payment.token)
    else
      redirect_to send("show_#{register_event_type}_path", id: @event_id)
    end
  end

  def save_registration_options
    params.permit(event_selections: {})[:event_selections].each do |_selection, option_id|
      @registration.registration_options.create!(event_option_id: option_id)
    end
  end

  def send_registered_emails
    RegistrationMailer.registered(@registration).deliver

    # If the event does not require advance payment, this will notify on create.
    #
    # Otherwise, a different notification will be sent, and the regular one will
    # be triggered by BraintreeController once the registration is paid for.
    if @registration.event.advance_payment && !@registration.reload.paid?
      RegistrationMailer.advance_payment(@registration).deliver
    else
      RegistrationMailer.confirm(@registration).deliver
    end

    slack_notification
  end

  def slack_notification
    SlackNotification.new(
      channel: :notifications, type: :warning, title: 'New Registration',
      fallback: 'Someone has registered for an event.',
      fields: slack_fields
    ).notify!
  end

  def slack_fields
    {
      'Event' => "<#{show_event_url(@registration.event)}|#{@registration.event.display_title}>",
      'Event date' => @registration.event.start_at.strftime(TimeHelper::SHORT_TIME_FORMAT),
      'Registrant name' => @registration&.name,
      'Registrant email' => @registration.email
    }.compact
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

  def block_url_data!
    return unless params.key?(:registration)
    return unless %i[name email phone].any? { |field| register_params[field] =~ %r{://} }

    unprocessable!
  end
end
