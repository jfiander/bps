# frozen_string_literal: true

class BraintreeController < ApplicationController
  include BraintreeHelper

  before_action :redirect_to_root, except: %i[refunds terms], unless: :braintree_enabled?

  before_action :load_payment, only: %i[index ask_to_pay checkout]

  before_action :transaction_details, only: %i[index ask_to_pay done]
  before_action :generate_client_token, only: %i[index ask_to_pay]
  before_action :block_duplicate_payments, if: :already_paid?, only: %i[
    index ask_to_pay checkout
  ]
  before_action :require_user, if: :has_user?, only: %i[
    index ask_to_pay checkout
  ]

  skip_before_action :verify_authenticity_token, only: [:checkout]

  def index
    #
  end

  def ask_to_pay
    #
  end

  def checkout
    nonce = clean_params[:payment_method_nonce]
    @receipt = cleanup_email(clean_params[:email])

    @result = @payment.sale!(nonce, email: @receipt, user_id: current_user&.id)

    @result_response = Payment.create_result_hash(@result.transaction)
    @result_flash = result_flash_for(@result_response[:message])

    if @result.success?
      @payment.paid!(@result.transaction.id)
      ReceiptMailer.receipt(@result.transaction, @payment).deliver
      ReceiptMailer.paid(@payment).deliver
      slack_notification(@payment)
      render js: "window.location='#{transaction_complete_path(token: @token)}'"
    else
      render js: <<~JS
        $('#alert').html('#{@result_flash[:alert]}').removeClass('hide');
        $('#error').html('#{@result_flash[:error]}').removeClass('hide');
      JS
    end
  end

  def done
    #
  end

  def refunds
    #
  end

  def terms
    #
  end

  private

  def generate_client_token
    @client_token = Payment.client_token(user_id: current_user&.id)
  end

  def slack_notification(payment)
    SlackNotification.new(
      type: :info, title: 'Payment Received',
      fallback: 'A payment was successfully completed.',
      fields: {
        'Amount' => "$#{payment.transaction_amount}",
        'Payment Token' => payment.token
      }
    ).notify!
  end
end
