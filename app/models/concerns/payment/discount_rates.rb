# frozen_string_literal: true

# Merchant discount rates for payments
module Concerns
  module Payment
    module DiscountRates
      extend ActiveSupport::Concern

      def self.discount(amount)
        # Fee is rounded down to the nearest cent
        fee = amount.to_d * 0.022 + 0.30
        fee.floor(2)
      end

      def discounted_amount
        amount.to_d - Payment.discount(amount)
      end
    end
  end
end
