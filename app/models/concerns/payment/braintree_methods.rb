# frozen_string_literal: true

# Braintree API implementation
module Concerns
  module Payment
    module BraintreeMethods
      extend ActiveSupport::Concern

      module ClassMethods
        TRANSACTION_SUCCESS_STATUSES = [
          Braintree::Transaction::Status::Authorizing,
          Braintree::Transaction::Status::Authorized,
          Braintree::Transaction::Status::Settled,
          Braintree::Transaction::Status::SettlementConfirmed,
          Braintree::Transaction::Status::SettlementPending,
          Braintree::Transaction::Status::Settling,
          Braintree::Transaction::Status::SubmittedForSettlement
        ].freeze

        def gateway
          Braintree::Gateway.new(
            environment: environment,
            merchant_id: ENV['BRAINTREE_MERCHANT_ID'],
            public_key: ENV['BRAINTREE_PUBLIC_KEY'],
            private_key: ENV['BRAINTREE_PRIVATE_KEY']
          )
        end

        def client_token(user_id: nil)
          customer = customer(user_id)
          opts = { customer_id: customer&.id }
          opts[:options] = { verify_card: true } if opts[:customer_id].present?
          gateway.client_token.generate(opts)
        end

        def create_result_hash(result)
          return success_hash if result.success?

          failed_hash(result)
        end

      private

        def environment
          allow_live_transactions? ? :production : :sandbox
        end

        def allow_live_transactions?
          ENV['ASSET_ENVIRONMENT'] == 'production' &&
            ENV['ENABLE_BRAINTREE'].present? &&
            ENV['ENABLE_BRAINTREE'] != 'disabled'
        end

        def customer(user_id = nil)
          return if user_id.nil?
          return unless (user = User.find_by(id: user_id))

          customer = find_customer(user)
          return customer if customer.present?

          create_customer(user)
        end

        def find_customer(user)
          gateway.customer.find(user.customer_id) if user.customer_id.present?
        rescue Braintree::NotFoundError
          nil
        end

        def create_customer(user)
          result = gateway.customer.create(
            first_name: user.first_name, last_name: user.last_name,
            email: user.email
          )

          if result.success?
            user.update(customer_id: result.customer.id)
          else
            p result.errors
          end
          result&.customer
        end

        def success_hash
          { status: :success, message: nil }
        end

        def failed_hash(result)
          {
            status: :failed,
            message: result&.message,
            errors: result&.errors&.map { |e| "Error: #{e.code}: #{e.message}" }
          }
        end
      end

      def sale!(nonce, email: nil, user_id: nil, postal_code: nil)
        self.class.gateway.transaction.sale(
          transaction_options(
            nonce, email: email, user_id: user_id, postal_code: postal_code
          )
        )
      end

      def refund!(refund_amount = nil)
        raise 'Not yet paid' unless transaction_id.present?
        return if refunded == true

        result = self.class.gateway.transaction.refund(transaction_id, to_refund(refund_amount))
        result.success? ? refund_success(result.transaction) : refund_failure(result)
        result
      end

      def refunded
        return true if read_attribute(:refunded)
        return false unless refunds.exists?

        refunds.pluck(:amount).map(&:to_d).sum.to_s
      end

      def remaining_paid
        ref = refunded
        return 0 if ref == true
        return nil unless paid?
        return amount unless ref

        (amount - ref.to_d).to_s
      end

      def transaction_options(nonce, email: nil, user_id: nil, postal_code: nil)
        options = {
          amount: amount,
          payment_method_nonce: nonce,
          options: braintree_options,
          custom_fields: custom_fields(user_id)
        }
        options[:customer] = { email: email } if email.present?
        options[:billing] = { postal_code: postal_code } if postal_code.present?

        options
      end

      def lookup_transaction
        return false unless paid?

        self.class.gateway.transaction.find(transaction_id)
      end

    private

      def custom_fields(user_id = nil)
        { rails_payment_token: token, rails_user_id: user_id }
      end

      def braintree_options
        {
          submit_for_settlement: true,
          store_in_vault_on_success: true,
          paypal: { description: purchase_subject }
        }
      end

      def to_refund(amount)
        amount = nil if amount > remaining_paid.to_d
        amount = "#{amount}.00" if amount.is_a?(Integer)
        amount
      end

      def refund_success(transaction)
        refunds.create!(amount: transaction.amount, transaction_id: transaction.id)

        update_attribute(:refunded, true) if refunded == true || refunded.to_d >= amount
      end

      def refund_failure(result)
        if result.transaction.processor_settlement_response_code == '4004'
          already_refunded(result.transaction)
        elsif result.transaction.status == 'settlement_declined'
          puts "\n*** Refund settlement was declined.\n\n", result.message, "\n"
        elsif result.errors.any?
          parse_validation_errors(result)
        else
          puts result.message
        end
      end

      def already_refunded(transaction)
        update_attribute(:refunded, true)

        puts "\n*** #{transaction.processor_settlement_response_text}\n"
      end

      def parse_validation_errors(result)
        result.errors.each do |e|
          update_attribute(:refunded, true) if e.code == '91512'

          puts "#{e.code}: #{e.message}"
        end
      end
    end
  end
end
