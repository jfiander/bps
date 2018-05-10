# frozen_string_literal: true

class ReceiptMailerPreview < ActionMailer::Preview
  def receipt
    transaction = gateway.transaction.sale(transaction_details).transaction
    ReceiptMailer.receipt(transaction, 'registration', Registration.last.id)
  end

  private

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
end
