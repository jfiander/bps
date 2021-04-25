# frozen_string_literal: true

module Events
  module Preload
    # This module defines no public methods.
    def _; end

  private

    def load_registrations
      @registered = Registration.includes(:payment).for_user(current_user)
                                .each_with_object({}) do |reg, hash|
        hash[reg.event_id] = { id: reg.id, paid: reg.paid? ? true : reg&.payment&.token }
      end
    end

    def load_notifications(map_to_text: false)
      @notifications = EventTypeCommittee.where(event_type_id: @event.event_type_id)
      return unless map_to_text

      @notifications = @notifications.flat_map(&:committees).flat_map(&:name).join("\n")
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
end
