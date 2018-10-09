# frozen_string_literal: true

module User::Register
  def register
    @event = Event.find_by(id: clean_params[:id])

    return if no_member_registrations? || no_registrations?

    register_for_event!

    if @registration.valid?
      successfully_registered
    elsif Registration.find_by(@registration.attributes.slice(:user_id, :event_id))
      already_registered
    else
      unable_to_register
    end
  end

  def cancel_registration
    @reg = Registration.find_by(id: clean_params[:id])

    return if cannot_cancel_registration?

    @cancel_link = (@reg&.user == current_user)

    if @reg&.paid?
      cannot_cancel_paid
    elsif @reg&.destroy
      successfully_cancelled
    else
      unable_to_cancel
    end
  end

  private

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

  def already_registered
    flash.now[:notice] = 'You are already registered for this course.'
    render status: :unprocessable_entity
  end

  def unable_to_register
    flash.now[:alert] = 'We are unable to register you at this time.'
    render status: :unprocessable_entity
  end

  def cannot_cancel_registration?
    return false if (@reg&.user == current_user) || current_user&.permitted?(:course, :seminar, :event, session: session)

    flash[:alert] = 'You are not allowed to cancel that registration.'
    redirect_to root_path, status: :unprocessable_entity
    true
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
