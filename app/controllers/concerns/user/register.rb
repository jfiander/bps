# frozen_string_literal: true

class User
  module Register
    def register
      @event = Event.find_by(id: clean_params[:id])

      return if no_member_registrations? || no_registrations?

      register_for_event!

      if @registration.valid?
        successfully_registered
      else
        unable_to_register
      end
    end

    def cancel_registration
      @reg = Registration.find_by(id: clean_params[:id])

      return unless can_cancel_registration?

      @cancel_link = (@reg&.user == current_user)

      if @reg&.paid?
        cannot_cancel_paid
      elsif @reg&.destroy
        successfully_cancelled
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

  private

    def find_registration
      @registration = Registration.find_by(id: clean_params[:id])
      @registration ||= Payment.find_by(token: clean_params[:token]).parent
    end

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
      params.require(:registration).permit(:override_cost, :override_comment)
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
      (@reg&.user == current_user) ||
        current_user&.permitted?(:course, :seminar, :event, session: session)
    end

    def successfully_cancelled
      flash[:success] = 'Successfully cancelled registration!'
      RegistrationMailer.cancelled(@reg).deliver if @cancel_link
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
