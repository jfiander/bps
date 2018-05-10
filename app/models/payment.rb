# frozen_string_literal: true

# Internal API for accessing Braintree payments.
class Payment < ApplicationRecord
  include Payments::ModelConfigs
  include Payments::BraintreeMethods

  belongs_to :parent, polymorphic: true
  has_secure_token

  def transaction_amount
    amount = parent.payment_amount
    amount.is_a?(Integer) ? "#{amount}.00" : amount
  end

  def paid!(transaction_id)
    update(paid: true, transaction_id: transaction_id)

    # Post-payment hooks
    parent.dues_paid! if parent_type == 'User'
  end
end
