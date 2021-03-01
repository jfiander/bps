# frozen_string_literal: true

class User
  module Receipts
    extend ActiveSupport::Concern

    included do
      secure!(
        :admin, strict: true, only: %i[receipts receipt override_cost paid_in_person refunded_payment]
      )

      before_action :find_payment, only: %i[receipt paid_in_person refunded_payment]
    end

    def receipts
      @payments = [
        payments.where(parent_type: 'Registration').includes(parent: :user),
        payments.where(parent_type: 'MemberApplication').includes(parent: :member_applicants),
        payments.where(parent_type: 'User').includes(:parent),
        payments.where(parent_type: 'GenericPayment').includes(:parent)
      ].flatten.compact.sort { |a, b| b.created_at <=> a.created_at }.select(&:cost?)
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

    def refunded_payment
      @payment.update(refunded: true)
      flash[:success] = 'Successfully marked as refunded.'
      redirect_to receipts_path
    end

  private

    def payments
      Payment.where('created_at > ?', 1.year.ago)
    end

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
end
