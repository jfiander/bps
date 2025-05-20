# frozen_string_literal: true

class RegistrationsController < ApplicationController
  title!('Registration')

  secure!(only: :destroy)

  before_action :redirect_if_existing, only: %i[new create]

  def show
    @registration = Registration.find(params[:id])
    @event = @registration.event
  end

  def new
    @registration = Registration.new(event_id: params[:event_id])
    @event = Event.find(params[:event_id])
  end

  def create
    additional_registrations = params[:registration].delete(:additional_registrations_attributes)

    @registration = Registration.new(registration_params.merge(user: current_user))

    registration_options_params&.each do |_description, option_id|
      @registration.registration_options.build(event_option_id: option_id)
    end

    process_additional_registrations(@registration, additional_registrations)

    @registration.save!

    successfully_registered

    redirect_to(registration_path(@registration))
  end

  def destroy
    registration = Registration.find(params[:id])

    text = registration.additional_registrations.any? ? 'these registrations' : 'this registration'

    Registration.transaction do
      registration.additional_registrations.destroy_all
      registration.destroy
    end

    flash[:success] = "You have successfully cancelled #{text}."

    redirect_to root_path
  end

private

  def registration_params
    params.require(:registration).permit(:event_id, :name, :email, :phone)
  end

  def registration_options_params
    params.permit(event_selections: {})[:event_selections]
  end

  def redirect_if_existing
    return unless user_signed_in?

    existing = Registration.find_by(event_id: params[:event_id], user: current_user)
    redirect_to(existing) if existing
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def process_additional_registrations(registration, additional_registrations)
    return unless additional_registrations

    parent_email = registration.user&.email || registration.email
    additional_emails = additional_registrations.each_value.pluck(:email)
    additional_emails +=
      User.where(certificate: additional_registrations.each_value.pluck(:certificate)).pluck(:email)

    additional_registrations.each_value do |details|
      user = User.find_by(certificate: details[:certificate]) if details[:certificate].present?

      matching_email = details[:email] == parent_email || details[:email].in?(additional_emails)
      email = details[:email] unless matching_email
      email ||= "nobody-#{SecureRandom.hex(8)}@bpsd9.org"

      additional = registration.additional_registrations.build(
        event_id: registration.event_id, name: details[:name], user: user, email: email
      )

      # details[:selections].each do |selection|
      #
      # end
      selection = details[:selections] # DEV
      additional.registration_options.build(event_option_id: selection)
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def successfully_registered
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

    registered_slack_notification
  end

  def registered_slack_notification
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
      'Registrant name' => @registration.user&.full_name(html: false),
      'Registrant email' => @registration.user&.email || @registration.email
    }.compact
  end
end
