# frozen_string_literal: true

module User::Receipts
  def receipts
    page_title('Receipts')
    @payments = Payment.includes(:parent).all.select(&:cost?)
  end

  def receipt
    if @payment.present? && @payment.cost?
      show_receipt
    else
      redirect_to root_path, notice: 'Receipt not available.'
    end
  end
  
  def paid_in_person
    @payment.in_person!
    flash[:success] = 'Successfully marked as paid in-person.'
    redirect_to receipts_path
  end

  private

  def find_payment
    @payment = Payment.find_by(token: receipt_params[:token])
  end
  
  def show_receipt
    @payment.receipt! unless @payment.receipt.exists?
    redirect_to @payment.receipt_link
  end

  def receipt_params
    params.permit(:token)
  end
end
