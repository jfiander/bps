# frozen_string_literal: true

module Events
  class EventsController < EventsBaseController
    secure!(:event, except: %i[schedule catalog show])
    title!('Events')

    def event_type_param
      'event'
    end
  end
end
