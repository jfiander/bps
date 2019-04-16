# frozen_string_literal: true

module BraintreeHelper
  # This module defines no public methods.
  def _; end

private

  def braintree_enabled?
    ENV['ENABLE_BRAINTREE'] == 'enabled' ||
      current_user.id.in?(ENV['ENABLE_BRAINTREE'].split(',').map(&:to_i))
  end

  def transaction_details
    @token = clean_params[:token]
    return unless @payment ||= Payment.find_by(token: @token)
    return not_payable unless payable_payment?

    @receipt = current_user&.email
    @transaction_amount = @payment.transaction_amount
    @purchase_info = @payment.purchase_info
    @purchase_subject = @payment.purchase_subject
  end

  def clean_params
    params.permit(:payment_method_nonce, :token, :email, :code)
  end

  def load_payment
    @token = clean_params[:token]
    @payment = Payment.find_by(token: @token)

    return payment_not_found if @payment.nil?
    return payment_no_cost unless @payment.cost?
    return payment_not_payable unless @payment.payable?
  end

  def payment_not_found
    flash[:alert] = 'Payment not found.'
    redirect_to root_path, status: :not_found
  end

  def payment_no_cost
    flash[:notice] = 'That has no cost.'
    redirect_to root_path, status: :bad_request
  end

  def payment_not_payable
    flash[:notice] = 'That is not eligible to be paid.'
    redirect_to root_path, status: :bad_request
  end

  def already_paid?
    @payment&.paid
  end

  def user?
    @payment&.parent_type == 'Registration' && @payable&.user?
  end

  def redirect_to_root
    flash[:notice] = "We're sorry, but payments are not currently enabled."
    redirect_to root_path
  end

  def block_duplicate_payments
    flash[:notice] = 'That has already been paid.'
    redirect_to root_path
  end

  def not_payable
    flash[:alert] = "Sorry – that isn't payable."
    redirect_to root_path
  end

  def require_user
    return if @payable&.user == current_user

    flash[:alert] = "Sorry – that wasn't your registration."
    redirect_to root_path
  end

  def valid_payable_models
    %w[registration member_application user]
  end

  def payable_payment?
    @payment.parent_type.in?(valid_payable_models.map(&:camelize))
  end

  def cleanup_email(email)
    URI.decode_www_form(email.gsub(/\Aemail=/, '')).flatten.first
  end

  def result_flash_for(status)
    {
      'failed' => failed_hash, 'gateway_rejected' => rejected_hash, 'voided' => voided_hash,
      'processor_declined' => declined_hash, 'unrecognized' => unrecognized_hash,
      'authorization_expired' => expired_hash, 'settlement_declined' => unsettled_hash,
      'Cannot use a payment_method_nonce more than once.' => nonce_hash
    }[status.to_s]
  end

  def failed_hash
    { alert: 'Your payment has failed.', error: 'Please try again.' }
  end

  def rejected_hash
    {
      alert: 'There was a problem processing your payment.',
      error: 'Please check the details and try again.'
    }
  end

  def declined_hash
    {
      alert: 'Your payment was declined.',
      error: 'Please choose another payment method, or contact your card issuer.'
    }
  end

  def unrecognized_hash
    { alert: 'There was an unrecognized error.', error: 'Please try again.' }
  end

  def expired_hash
    { alert: 'Your payment authorization has expired.', error: 'Please try again.' }
  end

  def unsettled_hash
    {
      alert: 'Your payment was declined at settlement.',
      error: 'Please choose another payment method.'
    }
  end

  def voided_hash
    { alert: 'This transaction has been voided.', error: 'Please try again.' }
  end

  def nonce_hash
    { alert: 'This page has expired.', error: 'Please refresh the page and try again.' }
  end
end
