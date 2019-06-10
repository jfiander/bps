# frozen_string_literal: true

module Events
  class CoursesController < EventsBaseController
    secure!(:course, except: %i[schedule catalog show])
    title!('Courses')

    def event_type_param
      'course'
    end
  end
end
