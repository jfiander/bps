# Preview all emails at http://localhost:3000/rails/mailers/receipt_mailer
class ReceiptMailerPreview < ActionMailer::Preview
  def receipt
    transaction = gateway.transaction.sale(transaction_details).transaction
    ReceiptMailer.receipt(transaction, 'registration', 42)
  end

  private

  def gateway
    Braintree::Gateway.new(
      environment: :sandbox,
      merchant_id: ENV['BRAINTREE_MERCHANT_ID'],
      public_key: ENV['BRAINTREE_PUBLIC_KEY'],
      private_key: ENV['BRAINTREE_PRIVATE_KEY']
    )
  end

  def transaction_details
    {
      amount: '10.00',
      payment_method_nonce: 'fake-valid-nonce',
      options: {
        submit_for_settlement: true
      }
    }
  end
end
