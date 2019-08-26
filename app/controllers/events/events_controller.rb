# frozen_string_literal: true

module Events
  class EventsController < EventController
    secure!(:event, except: %i[schedule catalog show slug])
    title!('Events')

    def event_type_param
      'event'
    end
  end
end
