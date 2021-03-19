# frozen_string_literal: true

# Internal API for tracking Braintree payment (partial) refunds.
class Refund < ApplicationRecord
  belongs_to :payment

  validates :payment_id, :amount, presence: true
end
