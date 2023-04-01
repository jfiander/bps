# frozen_string_literal: true

namespace :mail do
  desc 'Re-send receipt email'
  task :resend_receipt, [:payment_id] => :environment do |_task, args|
    payment = Payment.find(args.payment_id.to_i)
    raise '*** Paid in-person' if payment.transaction_id == 'in-person'

    transaction = payment.lookup_transaction
    ReceiptMailer.receipt(payment, transaction).deliver
  end
end
