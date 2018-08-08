# frozen_string_literal: true

# Internal API for accessing Braintree payments.
class Payment < ApplicationRecord
  include Payments::ModelConfigs
  include Payments::BraintreeMethods

  belongs_to :parent, polymorphic: true
  has_secure_token

  scope :recent, -> { where('created_at > ?', 11.months.ago) }
  scope :for_user, ->(user) { where(parent_type: 'User', parent_id: user.id) }

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
