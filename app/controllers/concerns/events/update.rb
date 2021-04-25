# frozen_string_literal: true

module Events
  module Update
    ATTACHMENTS = JSON.parse(
      File.read(Rails.root.join('app', 'controllers', 'concerns', 'events', 'attachments.json'))
    ).map(&:symbolize_keys).freeze

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

    # Magically update multi-value field associations from textarea input
    #
    # To add a new field, add its entry to attachments.json, and ensure that
    #   attachment_target supports its base association type
    def magic_update(field)
      attachment = ATTACHMENTS.find { |a| a[:key] == field.to_s }
      clean_params[field].split("\n").map(&:squish).uniq.each do |item|
        create_attachment(attachment, item)
      end
    end

    def create_attachment(attachment, value)
      return if value.nil?

      attachment[:model].constantize.create(
        attachment[:parent] => attachment_target(attachment[:parent]),
        attachment[:association] => (attachment[:map] ? send(attachment[:map], value) : value)
      )
    end

    def user_from_instructor(instructor)
      if instructor.match?(%r{/})
        User.find_by(certificate: instructor.split('/').last.squish.upcase)
      else
        User.with_name(instructor).first
      end
    end

    def attachment_target(association)
      case association
      when 'event', 'course'
        @event
      when 'event_type'
        @event.event_type
      else
        raise "Unknown association target: #{association}"
      end
    end

    def remove_old_attachments(clear_before_time)
      ATTACHMENTS.each do |attachment|
        attachment[:model].constantize.where(
          attachment[:parent] => attachment_target(attachment[:parent])
        ).where('updated_at < ?', clear_before_time).destroy_all
      end
    end
  end
end
