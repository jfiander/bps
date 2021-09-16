# frozen_string_literal: true

module Concerns
  module Event
    module Calendar
      extend ActiveSupport::Concern

      CALENDAR_COLUMNS = %i[
        event_type_id start_at length_h length_m sessions all_day description location_id
        online conference_id_cache link_override
      ].freeze

      def book!
        return if booked? || id.blank?

        calendar_update(call_if: true, set_to: :response) do
          calendar.create(calendar_hash)
        end
      end

      def unbook!
        return unless booked?

        calendar_update(call_if: on_calendar?, set_to: :nil) do
          calendar.delete(google_calendar_event_id)
        end
      end

      def refresh_calendar!
        return true if expired? || archived? # Skip, but allow update to continue
        return book! unless booked? && on_calendar?

        calendar_update(call_if: true, set_to: :response) do
          calendar.update(google_calendar_event_id, calendar_hash)
        end
      end

      def booked?
        google_calendar_event_id.present?
      end

      def on_calendar?
        event = calendar.get(google_calendar_event_id)
        event.present? && event.status != 'cancelled'
      rescue Google::Apis::ClientError
        false
      end

      def conference_id
        return conference_id_cache if conference_id_cache.present?
        return nil if google_calendar_event_id.blank?

        info = calendar.conference_info(google_calendar_event_id)
        return if info.nil?

        calendar_attributes ||= {}
        calendar_attributes[:conference_signature] = info[:signature]
        calendar_attributes[:conference_id_cache] = info[:id]
      rescue Google::Apis::ClientError
        nil
      end

      def conference_link
        return link_override if link_override.present?
        return unless (id = conference_id)

        "http://meet.google.com/#{id}"
      end

      def conference!(state: true)
        return if state && link_override.present?
        return if state && online && conference_id_cache.present?

        state ? enable_conference : remove_conference
      rescue Google::Apis::ClientError
        nil
      end

    private

      def calendar
        @calendar ||= GoogleAPI::Configured::Calendar.new(calendar_id)
      end

      def calendar_id(prod: false)
        return ENV['GOOGLE_CALENDAR_ID_TEST'] unless prod || Rails.env.production?

        if category.in?(%w[course seminar])
          ENV['GOOGLE_CALENDAR_ID_EDUC']
        else
          ENV['GOOGLE_CALENDAR_ID_GEN']
        end
      end

      def calendar_hash
        hash = {
          start: start_date, end: end_date, recurrence: recurrence,
          summary: calendar_summary, description: calendar_description,
          location: location&.one_line
        }
        if online
          if conference_signature.present?
            hash[:conference] = { id: conference_id, signature: conference_signature }
          elsif link_override.blank? && conference_id_cache.blank?
            hash[:conference] = { id: :new }
          end
        end

        hash
      end

      def recurrence
        return if all_day || !(sessions.present? && sessions > 1)

        ["RRULE:FREQ=#{repeat_pattern};COUNT=#{sessions}"]
      end

      def start_date
        return start_at.to_datetime unless all_day

        start_at.to_datetime.strftime('%Y-%m-%d')
      end

      def end_date
        return calculate_end_date unless all_day

        (start_at.to_datetime + (sessions&.days || 1)).strftime('%Y-%m-%d')
      end

      def calculate_end_date
        hours = length&.strftime('%H')&.to_i || 1
        minutes = length&.strftime('%M')&.to_i || 0

        start_at.to_datetime + hours.hours + minutes.minutes
      end

      def calendar_summary
        return summary if summary.present?
        return "Course: #{event_type.display_title}" if category == 'course'
        return "Seminar: #{event_type.display_title}" if category == 'seminar'

        event_type.display_title
      end

      def calendar_description
        strip_markdown.render(description.to_s).gsub("\n", "\n\n") +
          "\n\n#{link}\n\n*** Booked automatically by #{ENV['DOMAIN']} ***"
      end

      def strip_markdown
        Redcarpet::Markdown.new(Redcarpet::Render::StripDown)
      end

      def calendar_details_updated?
        CALENDAR_COLUMNS.any? { |field| send("saved_change_to_#{field}?") }
      end

      def calendar_update(call_if: true, set_to: nil)
        Rails.logger.silence do
          @calendar_attributes = {}
          response = yield if call_if
          set = { response: response, nil: nil }[set_to]
          store_calendar_details(set) if set_to.present?
          update_conference!(set)
          commit_calendar_attributes
          return response
        end
      end

      def store_calendar_details(response)
        if response&.id == google_calendar_event_id && response&.html_link == google_calendar_link
          return
        end

        calendar_attributes[:google_calendar_event_id] = response&.id
        calendar_attributes[:google_calendar_link] = response&.html_link
      end

      def update_conference!(info = nil)
        if online
          add_conference!(info) unless link_override.present? || conference_id_cache.present?
        else
          clear_conference_details
        end
      end

      def add_conference!(info = nil)
        @calendar_attributes ||= {}
        calendar_attributes[:conference_signature] = info.conference_data.signature
        calendar_attributes[:conference_id_cache] = info.conference_data.conference_id
      end

      def enable_conference
        return unless conference_id_cache.blank?

        event = calendar.add_conference(google_calendar_event_id)
        update_attributes(
          online: true,
          conference_signature: event.conference_data&.signature,
          conference_id_cache: event.conference_data&.conference_id
        )
      end

      def remove_conference
        calendar.patch(google_calendar_event_id, conference_data: nil)
        clear_conference_details
      end

      def clear_conference_details
        @calendar_attributes ||= {}
        calendar_attributes[:conference_id_cache] = nil
        calendar_attributes[:conference_signature] = nil
        calendar_attributes[:link_override] = nil
      end

      def commit_calendar_attributes
        update_columns(calendar_attributes) if calendar_attributes.any?
      end
    end
  end
end
