# frozen_string_literal: true

class ReceiptMailer < ApplicationMailer
  default from: '"Birmingham Power Squadron" <receipts@bpsd9.org>',
          reply_to: '"BPS Support" <support@bpsd9.org>',
          subject: 'Your receipt from Birmingham Power Squadron'

  def receipt(payment, transaction)
    @transaction = transaction_details(transaction, payment&.promo_code&.code)

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
    when 'GenericPayment'
      GenericPaymentMailer.paid(payment.parent) # Notify treasurer and webmaster
    end
  end

private

  def purchase_info(payment)
    @payment = payment
    @payable = @payment.parent

    case @payment.parent_type
    when 'Registration'
      registration_details
    when 'MemberApplication'
      member_application_details
    when 'User'
      dues_details
    end
  end

  def registration_details
    type = @payment.parent.type
    type = 'event' unless type.in?(%w[course seminar])

    {
      name: @payable.event.display_title,
      type: type,
      date: @payable.event.start_at.strftime(TimeHelper::PUBLIC_DATE_FORMAT),
      time: @payable.event.start_at.strftime(TimeHelper::PUBLIC_TIME_FORMAT),
      additional_registrations: @payable.additional_registrations
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

  def transaction_details(transaction, promo_code)
    return transaction if transaction.is_a?(Hash)

    @transaction = {
      id: transaction.id,
      date: transaction.created_at.strftime('%Y-%m-%d'),
      amount: transaction.amount,
      email: transaction.customer_details.email,
      promo_code: promo_code,
      payment: {
        credit_card: card_details(transaction),
        paypal: paypal_details(transaction),
        apple_pay: apple_pay_details(transaction)
      }
    }
  end

  def card_details(transaction)
    return unless transaction.payment_instrument_type == 'credit_card'

    {
      card_type: transaction.credit_card_details.card_type,
      image: transaction.credit_card_details.image_url,
      last_4: transaction.credit_card_details.last_4
    }
  end

  def paypal_details(transaction)
    return unless transaction.payment_instrument_type == 'paypal_account'

    {
      email: transaction.paypal_details.payer_email,
      image: transaction.paypal_details.image_url
    }
  end

  def apple_pay_details(transaction)
    return unless transaction.payment_instrument_type == 'apple_pay_card'

    {
      card_type: transaction.apple_pay_details.card_type,
      image: transaction.apple_pay_details.image_url,
      last_4: transaction.apple_pay_details.last_4
    }
  end
end
