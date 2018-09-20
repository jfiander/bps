# frozen_string_literal: true

class RegistrationMailer < ApplicationMailer
  include CommitteeNotificationEmails
  include MailerSignatures

  def registered(registration)
    @registration = registration
    @to_list = to_list

    mail(to: @to_list, subject: 'New registration')
    registered_slack_notification
  end

  def cancelled(registration)
    @registration = registration
    @to_list = to_list

    mail(to: @to_list, subject: 'Cancelled registration')
    cancelled_slack_notification
  end

  def confirm(registration)
    @registration = registration
    @signature = signature_for_confirm
    to = @registration&.user&.email || @registration.email
    from = "\"#{@signature[:name]}\" <#{@signature[:email]}>"
    attach_pdf if attachable?

    mail(to: to, from: from, subject: 'Registration confirmation')
  end

  def remind(registration)
    @registration = registration
    @signature = signature_for_confirm
    to = @registration&.user&.email || @registration.email
    from = "\"#{@signature[:name]}\" <#{@signature[:email]}>"

    mail(to: to, from: from, subject: 'Registration reminder')
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
    SlackNotification.new(
      type: type, title: title,
      fallback: fallback,
      fields: {
        'Event name' => @registration.event.display_title,
        'Event date' => @registration.event.start_at.strftime(ApplicationController::SHORT_TIME_FORMAT),
        'Registrant name' => @registration&.user&.full_name,
        'Registrant email' => @registration&.user&.email || @registration&.email
      }
    ).notify!
  end
end
