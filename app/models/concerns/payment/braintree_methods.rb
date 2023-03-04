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
            merchant_id: ENV.fetch('BRAINTREE_MERCHANT_ID', nil),
            public_key: ENV.fetch('BRAINTREE_PUBLIC_KEY', nil),
            private_key: ENV.fetch('BRAINTREE_PRIVATE_KEY', nil)
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
          Rails.env.production? &&
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
            Rails.logger.debug result.errors
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
    end
  end
end
