# frozen_string_literal: true

module Events
  class SeminarsController < ::EventController
    secure!(:seminar, except: %i[schedule catalog show])
    title!('Seminars')

    def event_type_param
      'seminar'
    end
  end
end
