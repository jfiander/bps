# frozen_string_literal: true

class User
  module RegisterPaid
    def override_cost
      return if @registration.is_a?(Registration)

      redirect_to receipts_path, alert: 'Can only override registration costs.'
    end

    def set_override_cost
      if @registration.update(reg_params)
        reg_params[:override_cost].to_i.zero? ? removed_flash : set_flash
      else
        flash[:alert] = 'Unable to override registration cost.'
      end

      redirect_to send("#{@registration.event.category}_registrations_path")
    end

    def collect_payment
      prepare_advance_payment(register: false)

      @receipt = @registration.primary&.user&.email || @registration.primary&.email
      modal(header: 'Advance Payment Required', status: :payment_required) do
        render_to_string partial: 'braintree/dropin'
      end
    end

  private

    def block_override
      return unless not_overrideable?

      if @registration.paid?
        flash[:notice] = 'That registration has already been paid.'
      elsif @registration.payment_amount&.zero?
        flash[:notice] = 'That registration has no cost.'
      end

      redirect_to override_path
    end

    def override_path
      cat = @registration.event.category.to_s == 'meeting' ? 'event' : @registration.event.category
      send("#{cat}_registrations_path")
    end

    def not_overrideable?
      @registration.paid? || @registration.payment_amount&.zero?
    end

    def payment_params
      params.permit(:token)
    end

    def require_payment
      prepare_advance_payment

      modal(header: 'Advance Payment Required', status: :payment_required) do
        render_to_string partial: 'events/modals/registered'
      end
    end

    def prepare_advance_payment(register: true)
      reg_and_token_for_advance(register)
      @client_token = Payment.client_token(user_id: current_user&.id)
      @transaction_amount = @registration.payment.transaction_amount
      @purchase_info = reg_purchase_info
    end

    def reg_and_token_for_advance(register)
      @registration = current_user.register_for(@event) if current_user && register
      @token ||= @registration&.payment&.token || payment_params[:token]
      @registration ||= Payment.find_by(token: @token).parent
      @event ||= @registration.event
    end

    def reg_purchase_info
      {
        name: @event.display_title, type: @event.category,
        date: @event.start_at.strftime(ApplicationController::PUBLIC_DATE_FORMAT),
        time: @event.start_at.strftime(ApplicationController::PUBLIC_TIME_FORMAT),
        codes_available: @event.promo_codes.any?
      }
    end

    def cannot_cancel_paid
      flash[:alert] = 'That registration has been paid, and cannot be cancelled.'
      render status: :unprocessable_entity
    end
  end
end
