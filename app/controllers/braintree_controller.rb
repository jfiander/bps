# frozen_string_literal: true

class BraintreeController < ApplicationController
  include BraintreeHelper

  before_action :redirect_to_root, except: %i[refunds terms], unless: :braintree_enabled?

  before_action :load_payment, only: %i[index set_promo ask_to_pay checkout]
  before_action :prepare_receipt_email, only: %i[checkout]

  before_action :transaction_details, only: %i[index set_promo ask_to_pay done]
  before_action :generate_client_token, only: %i[index set_promo ask_to_pay]
  before_action(
    :block_duplicate_payments, if: :already_paid?, only: %i[index set_promo ask_to_pay checkout]
  )
  before_action :require_user, if: :user?, only: %i[index set_promo ask_to_pay checkout]

  skip_before_action :verify_authenticity_token, only: [:checkout]

  def index; end

  def ask_to_pay; end

  def checkout
    @result = submit_transaction
    process_result

    if @result.success?
      process_success
      render js: "window.location='#{transaction_complete_path(token: @token)}'"
    else
      flash_error_message
    end
  rescue StandardError => e
    generic_error_message(e)
  end

  def set_promo
    if promo_params[:code].present?
      @purchase_info[:promo_code] = promo_params[:code]
      @payment.attach_promo_code(@purchase_info[:promo_code])
      @transaction_amount = @payment.transaction_amount
      @payment.parent.update(override_comment: "Promo Code: #{@purchase_info[:promo_code]}")
    end

    render :index
  end

  def done; end

  def refunds; end

  def terms; end

private

  def generate_client_token
    @client_token = Payment.client_token(user_id: current_user&.id)
  end

  def promo_params
    params.permit(:code)
  end

  def prepare_receipt_email
    @receipt = cleanup_email(clean_params[:email])
  end

  def submit_transaction
    @payment.sale!(clean_params[:payment_method_nonce], email: @receipt, user_id: current_user&.id)
  end

  def process_result
    @result_response = Payment.create_result_hash(@result)
    @result_flash = result_flash_for(@result_response[:message])
    @result_flash ||= {
      alert: 'There was a problem processing the transaction.',
      error: 'You have not been billed.'
    }
  end

  def slack_notification(payment)
    SlackNotification.new(
      channel: :notifications, type: :info, title: 'Payment Received',
      fallback: 'A payment was successfully completed.',
      fields: {
        'Amount' => payment.transaction_amount,
        'Receipt' => "<#{payment.receipt_link}|Receipt>"
      }.merge(promo_field(payment))
    ).notify!
  end

  def promo_field(payment)
    promo = payment&.promo_code&.code
    promo.present? ? { 'Promo code' => promo } : {}
  end

  def process_success
    transaction = @result.transaction
    @payment.paid!(transaction.id)
    ReceiptMailer.paid(@payment).deliver
    send_registration_email(@payment.parent)
    send_application_email(@payment.parent)
    send_receipt_email(transaction)
    slack_notification(@payment)
  end

  def send_receipt_email(transaction)
    return unless transaction.customer_details.email.present?

    ReceiptMailer.receipt(@payment, transaction).deliver
  end

  def send_registration_email(registration)
    return unless registration.is_a?(Registration) && registration.event.advance_payment

    registration.notify_on_create
    registration.confirm_to_registrant
  end

  def send_application_email(member_application)
    return unless member_application.is_a?(MemberApplication)

    MemberApplicationMailer.new_application(member_application).deliver
  end

  def flash_error_message
    render js: <<~JS
      $('#alert').html('#{@result_flash[:alert]}').removeClass('hide');
      $('#error').html('#{@result_flash[:error]}').removeClass('hide');
    JS
  end

  def generic_error_message(e)
    render js: <<~JS
      $('#alert').html('There was a problem processing the transaction.').removeClass('hide');
      $('#error').html('You have not been charged.').removeClass('hide');
    JS

    raise e
  end
end
