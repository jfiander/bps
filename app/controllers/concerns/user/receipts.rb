# frozen_string_literal: true

module User::Receipts
  def receipts
    @payments = Payment.includes(:parent).all.select(&:cost?)
  end

  def receipt
    @payment = Payment.find_by(token: receipt_params[:token])

    if @payment.present? && @payment.cost?
      @payment.receipt! unless @payment.receipt.present?
      redirect_to @payment.receipt_link
    else
      redirect_to root_path, notice: 'Receipt not available.'
    end
  end

  def receipt_params
    params.permit(:token)
  end
end
