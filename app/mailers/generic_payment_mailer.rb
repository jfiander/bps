# frozen_string_literal: true

class GenericPaymentMailer < ApplicationMailer
  include Rails.application.routes.url_helpers

  def paid(generic_payment)
    @generic_payment = generic_payment
    @to_list = ['treasurer@bpsd9.org', 'webmaster@bpsd9.org']

    slack_notification
    mail(to: @to_list, subject: 'Payment received')
  end

private

  def slack_notification
    SlackNotification.new(
      channel: :notifications, type: :info, title: 'Payment Received',
      fallback: 'Someone has submitted a payment.',
      fields: {
        'Description' => @generic_payment.description,
        'Name' => @generic_payment&.user&.full_name,
        'Email' => @generic_payment&.user&.email || @generic_payment&.email
      }
    ).notify!
  end
end
