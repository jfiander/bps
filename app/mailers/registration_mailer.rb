# frozen_string_literal: true

class RegistrationMailer < ApplicationMailer
  include CommitteeNotificationEmails
  include MailerSignatures
  include Rails.application.routes.url_helpers

  def registered(registration)
    @registration = registration
    @to_list = to_list

    mail(to: @to_list, subject: 'New registration')
  end

  def cancelled(registration)
    @registration = registration
    @to_list = to_list

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
    @from = @signature[:from]
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

  # Copied from MarkdownHelper
  # :nocov:
  def simple_markdown(markdown)
    view_context.sanitize(redcarpet.render(markdown.to_s))
  end
  helper_method :simple_markdown

  def redcarpet
    Redcarpet::Markdown.new(
      TargetBlankRenderer,
      autolink: true,
      images: true,
      tables: true,
      no_intra_emphasis: true,
      strikethrough: true,
      superscript: true,
      underline: true
    )
  end
  # :nocov:
end
