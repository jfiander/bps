module BraintreeHelper
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
    params.permit(:payment_method_nonce, :token, :email)
  end

  def load_payment
    @token = clean_params[:token]
    @payment = Payment.find_by(token: @token)

    return payment_not_found if @payment.nil?
    return payment_no_cost unless @payment.amount&.positive?
  end

  def payment_not_found
    flash[:alert] = 'Payment not found.'
    redirect_to root_path
  end

  def payment_no_cost
    flash[:notice] = 'That has no cost.'
    redirect_to root_path
  end

  def already_paid?
    @payment&.paid
  end

  def has_user?
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
      'failed' => { alert: 'Your payment has failed.', error: 'Please try again.' },
      'gateway_rejected' => { alert: 'There was a problem processing your payment.', error: 'Please check the details and try again.' },
      'processor_declined' => { alert: 'Your payment was declined.', error: 'Please choose another payment method, or contact your card issuer.' },
      'unrecognized' => { alert: 'There was an unrecognized error.', error: 'Please try again.' },
      'authorization_expired' => { alert: 'Your payment authorization has expired.', error: 'Please try again.' },
      'settlement_declined' => { alert: 'Your payment was declined at settlement.', error: 'Please choose another payment method.' },
      'voided' => { alert: 'This transaction has been voided.', error: 'Please try again.' },
      'Cannot use a payment_method_nonce more than once.' => { alert: 'This page has expired.', error: 'Please refresh the page and try again.' }
    }[status.to_s]
  end
end
