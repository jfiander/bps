# frozen_string_literal: true

module Members
  module Dues
    extend ActiveSupport::Concern

    included do
      before_action :prepare_dues, only: :dues, if: :current_user_dues_due?
    end

    def dues
      dues_not_payable unless @payment.present?
    end

  private

    def current_user_dues_due?
      current_user&.dues_due?
    end

    def prepare_dues
      @payment = Payment.recent.for_user(current_user).first
      @payment ||= Payment.create(parent_type: 'User', parent_id: current_user.id)
      transaction_details
      set_dues_instance_variables
    end

    def set_dues_instance_variables
      @token = @payment.token
      @client_token = Payment.client_token(user_id: current_user&.id)
      @receipt = current_user.email
    end

    def dues_not_payable
      if current_user.parent_id.present?
        flash[:alert] = 'Additional household members cannot pay dues.'
      else
        flash[:notice] = 'Your dues for this year are not yet due.'
      end
      redirect_to root_path
    end
  end
end
