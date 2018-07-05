# frozen_string_literal: true

class Events::EventsController < EventsController
  secure!(:event, except: %i[schedule catalog show])
  title!('Events')

  def event_type_param
    'event'
  end
end
