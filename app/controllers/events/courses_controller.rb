# frozen_string_literal: true

class Events::CoursesController < EventsController
  secure!(:course, except: %i[schedule catalog show])
  title!('Courses')

  def event_type_param
    'course'
  end
end
