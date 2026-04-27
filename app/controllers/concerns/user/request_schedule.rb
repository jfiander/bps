# frozen_string_literal: true

class User
  module RequestSchedule
    def request_schedule
      @event = Event.find_by(id: clean_params[:id])

      RegistrationMailer.request_schedule(@event.event_type, by: current_user).deliver
      flash[:success] = "#{@event.category.titleize} requested!"
    end
  end
end
