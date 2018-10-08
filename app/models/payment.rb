# frozen_string_literal: true

# Internal API for accessing Braintree payments.
class Payment < ApplicationRecord
  include Payments::ModelConfigs
  include Payments::BraintreeMethods

  belongs_to :parent, polymorphic: true
  has_secure_token

  scope :recent, -> { where('created_at > ?', 11.months.ago) }
  scope :for_user, ->(user) { where(parent_type: 'User', parent_id: user.id) }

  def self.discount(amount)
    # Fee is rounded down to the nearest cent
    fee = amount.to_d * 0.022 + 0.30
    fee.floor(2)
  end

  def amount
    parent.payment_amount
  end

  def transaction_amount
    amount.is_a?(Integer) ? "#{amount}.00" : amount
  end

  def discounted_amount
    transaction_amount.to_d - Payment.discount(transaction_amount)
  end

  def paid!(transaction_id)
    update(paid: true, transaction_id: transaction_id)

    # Post-payment hooks
    parent.dues_paid! if parent_type == 'User'
  end
end
