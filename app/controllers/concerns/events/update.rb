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
        update_includes
        update_topics
        update_instructors
      end
    end

    def event_attachments
      update_or_remove { update_notifications }
    end

    # Update various attachments, then remove any that were not updated
    def update_or_remove
      Event.transaction do
        clear_before_time = Time.now - 1.second
        yield
        remove_old_attachments(clear_before_time)
      end
    end

    def update_notifications
      clean_params[:notifications].split("\n").map(&:squish).uniq.each do |c|
        EventTypeCommittee.create(event_type_id: @event.event_type_id, committee: c)
      end
    end

    def update_includes
      clean_params[:includes].split("\n").map(&:squish).uniq.each do |i|
        CourseInclude.create(course: @event, text: i)
      end
    end

    def update_topics
      clean_params[:topics].split("\n").map(&:squish).uniq.each do |t|
        CourseTopic.create(course: @event, text: t)
      end
    end

    def update_instructors
      clean_params[:instructors].split("\n").map(&:squish).uniq.each do |user|
        user = find_user_for_instructor(user)
        EventInstructor.create(event: @event, user: user) if user.present?
      end
    end

    def find_user_for_instructor(user)
      if user.match?(%r{/})
        User.find_by(certificate: user.split('/').last.squish.upcase)
      else
        User.with_name(user).first
      end
    end

    def remove_old_attachments(clear_before_time)
      EventTypeCommittee.where(event_type_id: @event.event_type_id).where(
        'updated_at < ?', clear_before_time
      ).destroy_all

      remove_old_education_attachments(clear_before_time)
    end

    def remove_old_education_attachments(clear_before_time)
      CourseInclude.where(course: @event).where(
        'updated_at < ?', clear_before_time
      ).destroy_all

      CourseTopic.where(course: @event).where(
        'updated_at < ?', clear_before_time
      ).destroy_all

      EventInstructor.where(event: @event).where(
        'updated_at < ?', clear_before_time
      ).destroy_all
    end
  end
end
