module User::Register
  def register
    @event_id = clean_params[:id]
    @event = Event.find_by(id: @event_id)
    unless @event.allow_member_registrations
      flash.now[:alert] = 'This course is not currently accepting member registrations.'
      render status: :unprocessable_entity and return
    end

    unless @event.registerable?
      flash.now[:alert] = 'This course is no longer accepting registrations.'
      render status: :unprocessable_entity and return
    end

    @registration = current_user.register_for(Event.find_by(id: @event_id))

    if @registration.valid?
      flash[:success] = 'Successfully registered!'
      RegistrationMailer.confirm(@registration).deliver
    elsif Registration.find_by(@registration.attributes.slice(:user_id, :event_id))
      flash.now[:notice] = 'You are already registered for this course.'
      render status: :unprocessable_entity
    else
      flash.now[:alert] = 'We are unable to register you at this time.'
      render status: :unprocessable_entity
    end
  end

  def cancel_registration
    @reg_id = clean_params[:id]
    r = Registration.find_by(id: @reg_id)
    @event_id = r&.event_id

    unless (r&.user == current_user) || current_user&.permitted?(:course, :seminar, :event)
      flash[:alert] = 'You are not allowed to cancel that registration.'
      redirect_to root_path, status: :unprocessable_entity
    end

    @cancel_link = (r&.user == current_user)

    if r&.destroy
      flash[:success] = 'Successfully cancelled registration!'
      RegistrationMailer.cancelled(r).deliver if @cancel_link
    else
      flash.now[:alert] = 'We are unable to cancel your registration at this time.'
      render status: :unprocessable_entity
    end
  end
end
