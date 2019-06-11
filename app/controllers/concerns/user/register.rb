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

  private

    def reg_params
      params.require(:registration).permit(:id, :override_cost, :override_comment)
    end

    def additional_params
      params.require(:registration).permit(
        user_registrations_attributes: %i[certificate email]
      )[:user_registrations_attributes]['0']
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
  end
end
