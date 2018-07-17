# frozen_string_literal: true

module Events::Preload
  private

  def load_registrations
    @registered = Registration.includes(:user).where(user_id: current_user.id)
                              .map { |r| { r.event_id => r.id } }
                              .reduce({}, :merge)
  end

  def load_includes(map_to_text: false)
    @course_includes = CourseInclude.where(course_id: @event.id)
    return unless map_to_text

    @course_includes = @course_includes.map(&:text).join("\n")
  end

  def load_topics(map_to_text: false)
    @course_topics = CourseTopic.where(course_id: @event.id)
    return unless map_to_text

    @course_topics = @course_topics.map(&:text).join("\n")
  end

  def load_instructors(map_to_text: false)
    @instructors = EventInstructor.where(event_id: @event.id).map(&:user)
    return unless map_to_text

    @instructors = @instructors.map do |u|
      "#{u.simple_name} / #{u.certificate}"
    end.join("\n")
  end
end
