# frozen_string_literal: true

class User
  module Register
    def register
      @event = Event.find_by(id: clean_params[:id])

      return if no_member_registrations? || no_registrations?

      return require_payment if @event.advance_payment

      register_for_event!

      if @registration.valid?
        successfully_registered
      else
        unable_to_register
      end
    end

    def add_registrants
      @registration = Registration.find_by(id: reg_params[:id])
      certificate = additional_params[:certificate]
      email = additional_params[:email]
      UserRegistration.create(
        registration: @registration, primary: false, certificate: certificate, email: email
      )

      load_registered_list
    end

    def cancel_registration
      return unless can_cancel_registration?

      @cancel_link = (@registration&.user == current_user)

      if @registration&.paid?
        cannot_cancel_paid
      elsif @registration&.destroy
        successfully_cancelled
        render content_type: 'text/javascript'
      else
        unable_to_cancel
      end
    end

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

    def reg_params
      params.require(:registration).permit(:id, :override_cost, :override_comment)
    end

    def additional_params
      params.require(:registration).permit(
        user_registrations_attributes: [:certificate, :email]
      )[:user_registrations_attributes]['0']
    end

    def payment_params
      params.permit(:token)
    end

    def load_registered_list
      # html_safe: Text is sanitized before display
      @registered = view_context.content_tag(:ul, class: 'simple') do
        view_context.safe_join(
          @registration.user_registrations.map do |ur|
            contents = sanitize(ur&.user&.full_name || ur&.email)
            view_context.content_tag(:li, contents).html_safe
          end
        )
      end
    end

    def set_flash
      flash[:success] = 'Successfully overrode registration cost.'
    end

    def removed_flash
      flash[:success] = 'Successfully removed override registration cost.'
    end

    def no_member_registrations?
      return false if @event.allow_member_registrations

      flash.now[:alert] = 'This course is not accepting member registrations.'
      render status: :unprocessable_entity
      true
    end

    def no_registrations?
      return false if @event.registerable?

      flash.now[:alert] = 'This course is no longer accepting registrations.'
      render status: :unprocessable_entity
      true
    end

    def register_for_event!
      @registration = current_user.register_for(@event)
    end

    def successfully_registered
      flash[:success] = 'Successfully registered!'
      @registration.notify_new
      @registration.confirm_to_registrants

      modal(header: 'You are now registered!') do
        render_to_string partial: 'events/modals/registered'
      end
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

    def unable_to_register
      flash.now[:alert] = 'We are unable to register you at this time.'
      render status: :unprocessable_entity
    end

    def can_cancel_registration?
      return true if allowed_to_cancel?

      flash[:alert] = 'You are not allowed to cancel that registration.'
      redirect_to root_path, status: :unprocessable_entity
      false
    end

    def allowed_to_cancel?
      (@registration&.user == current_user) ||
        current_user&.permitted?(:course, :seminar, :event, session: session)
    end

    def successfully_cancelled
      flash[:success] = 'Successfully cancelled registration!'
      RegistrationMailer.cancelled(@registration).deliver if @cancel_link
    end

    def unable_to_cancel
      flash.now[:alert] = 'We are unable to cancel your registration.'
      render status: :unprocessable_entity
    end

    def cannot_cancel_paid
      flash[:alert] = 'That registration has been paid, and cannot be cancelled.'
      render status: :unprocessable_entity
    end
  end
end
