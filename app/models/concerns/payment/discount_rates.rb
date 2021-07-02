# frozen_string_literal: true

# Merchant discount rates for payments
module Concerns
  module Payment
    # Braintree fees:
    # 2.2% + $0.30 per transaction for Visa, Mastercard, Discover, JCB and Diners Clubs cards, as well as digital wallets
    # 3.25% + $0.30 per transaction for American Express cards
    #
    # PayPal fees:
    #   previously: 2.2% + $0.30
    #   after 8/2/2021: 1.9% + $0.49
    module DiscountRates
      extend ActiveSupport::Concern

      def self.discount(amount, transaction: nil)
        fee = flat_discount(paypal: paypal?(transaction))
        fee += percent_discount(
          amount,
          paypal: paypal?(transaction),
          amex: amex?(transaction),
          usd: true,
          foreign: false
        )

        # Fee is rounded down to the nearest cent
        fee.floor(2)
      end

      def discounted_amount
        amount.to_d - Payment.discount(amount)
      end

    private

      def paypal?(transaction)
        transaction.credit_card_details.card_type == 'PayPal'
      end

      def amex?(transaction)
        transaction.credit_card_details.card_type == 'AMEX'
      end

      def flat_discount(paypal: false)
        paypal ? 0.49 : 0.30
      end

      def percent_discount(amount, paypal: false, amex: false, usd: true, foreign: false)
        percent = base_percent_discount(paypal: paypal, amex: amex)
        percent += usd_percent_discount(usd: usd)
        percent += foreign_card_percent_discount(foreign: foreign)

        fee += amount.to_d * percent
      end

      def base_percent_discount(paypal: false, amex: false)
        if paypal
          0.019
        elsif amex
          0.0325
        else
          0.022
        end
      end

      # An additional 1% fee applies to transactions presented in any non-USD currency
      def usd_percent_discount(usd: true)
        usd ? 0 : 0.01
      end

      # An additional 1% fee applies when the customer's card is issued outside of the United States
      def foreign_card_percent_discount(foreign: false)
        foreign ? 0 : 0.01
      end
    end
  end
end
