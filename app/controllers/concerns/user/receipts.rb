# frozen_string_literal: true

module User::Receipts
  def receipts
    @payments = Payment.includes(:parent).all.select(&:cost?)
  end

  def receipt
    find_payment

    if @payment.present? && @payment.cost?
      show_receipt
    else
      redirect_to root_path, notice: 'Receipt not available.'
    end
  end
  
  private

  def find_payment
    @payment = Payment.find_by(token: receipt_params[:token])
  end
  
  def show_receipt
    @payment.receipt! unless @payment.receipt.present?
    redirect_to @payment.receipt_link
  end

  def receipt_params
    params.permit(:token)
  end
end
