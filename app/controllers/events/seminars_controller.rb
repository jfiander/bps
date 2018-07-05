# frozen_string_literal: true

class Events::SeminarsController < EventsController
  secure!(:seminar, except: %i[schedule catalog show])
  title!('Seminars')

  def event_type_param
    'seminar'
  end
end
