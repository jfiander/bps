# frozen_string_literal: true

module Admin
  class GenericPaymentsController < ApplicationController
    secure!(:admin, strict: true)

    before_action :users, only: :new

    def index
      @generic_payments = GenericPayment.all
    end

    def new
      @generic_payment = GenericPayment.new
    end

    def create
      @generic_payment = GenericPayment.create(generic_payment_params)

      if @generic_payment.valid?
        redirect_to(
          admin_generic_payments_path,
          success: 'Successfully created Generic Payment.'
        )
      else
        failed_to_save
      end
    end

  private

    def generic_payment_params
      params.require(:generic_payment).permit(:description, :amount, :user_id, :email)
    end

    def users
      @users = User.unlocked.include_positions.order(:last_name).map do |user|
        [
          user&.full_name.blank? ? user.email : user.full_name(html: false),
          user.id
        ]
      end
    end

    def failed_to_save
      flash.now[:alert] = 'Unable to create Generic Payment.'
      flash.now[:error] = @generic_payment.errors.full_messages
      users
      render :new
    end
  end
end
