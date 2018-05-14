class RegistrationMailer < ApplicationMailer
  include CommitteeNotificationEmails
  include MailerSignatures

  def registered(registration)
    @registration = registration
    @committee_chairs = load_committee_chairs
    @to_list = to_list

    mail(to: @to_list, subject: 'New registration')
    registered_slack_notification
  end

  def cancelled(registration)
    @registration = registration
    @committee_chairs = load_committee_chairs
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

  private

  def signature_for_confirm
    if @registration.event.category == :event
      ao_signature
    else
      seo_signature
    end
  end

  def attach_pdf
    flyer = @registration.event.flyer
    data = Paperclip.io_adapters.for(flyer).read
    name = @registration.event.event_type.display_title.delete("' ")
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
        'Event name' => @registration.event.event_type.display_title,
        'Event date' => @registration.event.start_at.strftime('%-m/%-d @ %H%M'),
        'Registrant name' => @registration&.user&.full_name,
        'Registrant email' => @registration&.user&.email || @registration&.email
      }
    ).notify!
  end
end
