# frozen_string_literal: true

# Braintree API implementation
module Payments::BraintreeMethods
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
      gateway.client_token.generate(customer_id: customer&.id)
    end

    def create_result_hash(transaction)
      status = transaction.status

      if TRANSACTION_SUCCESS_STATUSES.include? status
        success_hash
      else
        failed_hash(status, @result)
      end
    end

    private

    def environment
      return :sandbox unless ENV['ENABLE_BRAINTREE'] == 'enabled'
      return :sandbox unless ENV['ASSET_ENVIRONMENT'] == 'production'
      :sandbox
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
        first_name: user.first_name,
        last_name: user.last_name,
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

    def failed_hash(status, result)
      {
        status: :failed,
        message: status,
        errors: result.errors.map do |error|
          "Error: #{error.code}: #{error.message}"
        end
      }
    end
  end

  def sale!(nonce, email: nil, user_id: nil)
    self.class.gateway.transaction.sale(
      transaction_options(nonce, email: email, user_id: user_id)
    )
  end

  def transaction_options(nonce, email: nil, user_id: nil)
    options = {
      amount: parent.payment_amount,
      payment_method_nonce: nonce,
      options: braintree_options,
      custom_fields: custom_fields(user_id)
    }
    options[:customer] = { email: email } if email.present?

    options
  end

  private

  def custom_fields(user_id = nil)
    { rails_payment_token: token, rails_user_id: user_id }
  end

  def braintree_options
    {
      submit_for_settlement: true,
      store_in_vault_on_success: true
    }
  end
end
