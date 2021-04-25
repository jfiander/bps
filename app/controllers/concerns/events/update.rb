# frozen_string_literal: true

module Events
  module Update
    # This module defines no public methods.
    def _; end

  private

    def update_attachments
      event_type_param.in?(%w[course seminar]) ? education_attachments : event_attachments
    end

    def education_attachments
      update_or_remove do
        magic_update(:includes)
        magic_update(:topics)
        magic_update(:instructors)
      end
    end

    def event_attachments
      update_or_remove { magic_update(:notifications) }
    end

    # Update various attachments, then remove any that were not updated
    def update_or_remove
      Event.transaction do
        clear_before_time = Time.now - 1.second
        yield
        remove_old_attachments(clear_before_time)
      end
    end

    def magic_update(field)
      method = "create_#{field.to_s.sub(/s$/, '')}"
      clean_params[field].split("\n").map(&:squish).uniq.each { |item| send(method, item) }
    end

    def create_include(inc)
      CourseInclude.create(course: @event, text: inc)
    end

    def create_topic(topic)
      CourseTopic.create(course: @event, text: topic)
    end

    def create_instructor(instructor)
      user = find_user_for_instructor(instructor)
      EventInstructor.create(event: @event, user: user) if user.present?
    end

    def find_user_for_instructor(instructor)
      if instructor.match?(%r{/})
        User.find_by(certificate: instructor.split('/').last.squish.upcase)
      else
        User.with_name(instructor).first
      end
    end

    def create_notification(committee)
      EventTypeCommittee.create(event_type_id: @event.event_type_id, committee: committee)
    end

    def attachments
      [
        EventTypeCommittee.where(event_type_id: @event.event_type_id),
        CourseInclude.where(course: @event),
        CourseTopic.where(course: @event),
        EventInstructor.where(event: @event)
      ]
    end

    def remove_old_attachments(clear_before_time)
      attachments.each do |relation|
        relation.where('updated_at < ?', clear_before_time).destroy_all
      end
    end
  end
end
