# frozen_string_literal: true

class GenericPaymentMailer < ApplicationMailer
  include Rails.application.routes.url_helpers

  def paid(generic_payment)
    @generic_payment = generic_payment
    @to_list = ['treasurer@bpsd9.org', 'webmaster@bpsd9.org']

    mail(to: @to_list, subject: 'Payment received')
  end
end
