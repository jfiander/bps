# frozen_string_literal: true

class ReceiptMailerPreview < ApplicationMailerPreview
  def receipt
    ReceiptMailer.receipt(payment, transaction)
  end

  def receipt_manual
    ReceiptMailer.receipt(payment, manual_options)
  end

  def receipt_with_promo_code
    ReceiptMailer.receipt(payment_with_promo_code, transaction)
  end

private

  def payment
    Payment.new
  end

  def payment_with_promo_code
    Payment.new(promo_code: PromoCode.new(code: 'testing123', valid_at: 1.hour.ago))
  end

  def transaction
    gateway.transaction.sale(transaction_details).transaction
  end

  # Dedicated, separate gateway instance that is always sandboxed for preview.
  def gateway
    Braintree::Gateway.new(
      environment: :sandbox,
      merchant_id: ENV['BRAINTREE_MERCHANT_ID'],
      public_key: ENV['BRAINTREE_PUBLIC_KEY'],
      private_key: ENV['BRAINTREE_PRIVATE_KEY']
    )
  end

  def transaction_details
    fake_nonces = %w[fake-valid-nonce fake-paypal-one-time-nonce]

    {
      amount: '10.00',
      payment_method_nonce: fake_nonces.sample,
      options: { submit_for_settlement: true },
      customer: { email: 'test-customer@example.com' }
    }
  end

  def manual_options
    {
      id: 'test-id',
      amount: '11.00',
      date: '2018-03-07',
      card_type: 'Visa',
      last_4: '1234'
    }
  end
end
