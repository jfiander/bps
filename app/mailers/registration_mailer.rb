# frozen_string_literal: true

class RegistrationMailer < ApplicationMailer
  include CommitteeNotificationEmails
  include MailerSignatures
  include Rails.application.routes.url_helpers

  def registered(registration)
    @registration = registration
    @to_list = to_list

    registered_slack_notification
    mail(to: @to_list, subject: 'New registration')
  end

  def cancelled(registration)
    @registration = registration
    @to_list = to_list

    cancelled_slack_notification
    mail(to: @to_list, subject: 'Cancelled registration')
  end

  def confirm(registration)
    generic_details(registration)

    mail(to: @to, from: @from, subject: 'Registration confirmation')
  end

  def advance_payment(registration)
    generic_details(registration)

    mail(to: @to, from: @from, subject: 'Registration pending')
  end

  def remind(registration)
    generic_details(registration)

    mail(to: @to, from: @from, subject: 'Registration reminder')
  end

  def paid(registration)
    @registration = registration
    @to_list = to_list << 'treasurer@bpsd9.org'

    mail(to: @to_list, subject: 'Registration paid')
  end

  def request_schedule(event_type, by: nil)
    @to_list = ['seo@bpsd9.org', 'aseo@bpsd9.org']
    @to_list += get_chair_email(event_type.event_category)
    @event_type = event_type
    @by = by

    mail(to: @to_list, subject: 'Educational request')
  end

private

  def generic_details(registration)
    @registration = registration
    @signature = signature_for_confirm
    @to = @registration&.user&.email || @registration.email
    @from = "\"#{@signature[:name]}\" <#{@signature[:email]}>"
    attach_pdf if attachable?
  end

  def signature_for_confirm
    if @registration.event.category == 'meeting'
      ao_signature
    else
      seo_signature
    end
  end

  def attach_pdf
    flyer = @registration.event.flyer
    data = Paperclip.io_adapters.for(flyer).read
    name = @registration.event.display_title.delete("' ")
    attachments["#{name}.pdf"] = data
  end

  def attachable?
    @registration.event.flyer.present? &&
      @registration.event.flyer.content_type == 'application/pdf'
  end

  def registered_slack_notification
    slack_notification(
      :info,
      'Registration Received',
      'Someone has registered for an event.'
    )
  end

  def cancelled_slack_notification
    slack_notification(
      :warning,
      'Registration Cancelled',
      'Someone has cancelled their registration for an event.'
    )
  end

  def slack_notification(type, title, fallback)
    return if @registration.event.id.nil?

    SlackNotification.new(
      channel: :notifications, type: type, title: title,
      fallback: fallback,
      fields: slack_fields
    ).notify!
  end

  def slack_fields
    {
      'Event' => "<#{show_event_url(@registration.event)}|#{@registration.event.display_title}>",
      'Event date' => slack_start_time,
      'Registrant name' => @registration&.user&.full_name,
      'Registrant email' => @registration&.user&.email || @registration&.email
    }.reject { |_, v| v.nil? }
  end

  def slack_start_time
    @registration.event.start_at.strftime(ApplicationController::SHORT_TIME_FORMAT)
  end
end
