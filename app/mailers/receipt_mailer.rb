# frozen_string_literal: true

class ReceiptMailer < ApplicationMailer
  default from: '"Birmingham Power Squadron" <receipts@bpsd9.org>'
  default subject: 'Your receipt from Birmingham Power Squadron'

  def receipt(payment, transaction)
    @transaction = transaction_details(transaction)

    @purchase_info = purchase_info(payment)
    @purchase_model = payment.parent_type

    mail(to: @transaction[:email])
  end

  def self.paid(payment)
    case payment.parent_type
    when 'Registration'
      RegistrationMailer.paid(payment.parent)
    when 'MemberApplication'
      MemberApplicationMailer.paid(payment.parent)
    when 'User'
      MemberApplicationMailer.paid_dues(payment.parent)
    end
  end

private

  def purchase_info(payment)
    @payment = payment
    @payable = @payment.parent

    if @payment.parent_type == 'Registration'
      registration_details
    elsif @payment.parent_type == 'MemberApplication'
      member_application_details
    elsif @payment.parent_type == 'User'
      dues_details
    end
  end

  def registration_details
    type = @payment.parent.type
    type = 'event' unless type.in?(%w[course seminar])

    {
      name: @payable.event.display_title,
      type: type,
      date: @payable.event.start_at.strftime(ApplicationController::PUBLIC_DATE_FORMAT),
      time: @payable.event.start_at.strftime(ApplicationController::PUBLIC_TIME_FORMAT)
    }
  end

  def member_application_details
    {
      name: 'Membership application',
      people: @payable.member_applicants.count
    }
  end

  def dues_details
    {
      name: 'Annual dues',
      people: @payable.children.count
    }
  end

  def transaction_details(transaction)
    return transaction if transaction.is_a?(Hash)

    @transaction = {
      id: transaction.id,
      date: transaction.created_at.strftime('%Y-%m-%d'),
      amount: transaction.amount,
      type: transaction.credit_card_details.card_type,
      image: transaction.credit_card_details.image_url,
      last_4: transaction.credit_card_details.last_4,
      email: transaction.customer_details.email
    }
  end
end
