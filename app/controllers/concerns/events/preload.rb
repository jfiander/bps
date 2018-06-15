# frozen_string_literal: true

module Events::Preload
  private

  def load_registrations
    @registered = Registration.includes(:user).where(user_id: current_user.id)
                              .map { |r| { r.event_id => r.id } }
                              .reduce({}, :merge)
  end

  def load_includes
    @course_includes = CourseInclude.where(course_id: @event.id).map(&:text)
                                    .join("\n")
  end

  def load_topics
    @course_topics = CourseTopic.where(course_id: @event.id).map(&:text)
                                .join("\n")
  end

  def load_instructors
    @instructors = EventInstructor.where(event_id: @event.id).map(&:user)
                                  .map do |u|
                                    "#{u.simple_name} / #{u.certificate}"
                                  end.join("\n")
  end
end
