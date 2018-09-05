# frozen_string_literal: true

module User::RequestSchedule
  def request_schedule
    @event = Event.find_by(id: clean_params[:id])

    RegistrationMailer.request_schedule(@event.event_type)
  end
end
