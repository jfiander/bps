# frozen_string_literal: true

module Concerns
  module Event
    module Calendar
      extend ActiveSupport::Concern

      def book!
        return if booked? || id.blank?

        calendar_update(call_if: true, set_to: :response) do
          calendar.create(calendar_hash)
        end
      rescue StandardError => e
        Bugsnag.notify(e)
      end

      def unbook!
        return unless booked?

        calendar_update(call_if: on_calendar?, set_to: :nil) do
          calendar.delete(google_calendar_event_id)
        end
      rescue StandardError => e
        Bugsnag.notify(e)
      end

      def refresh_calendar!
        return true if expired? || archived? # Skip, but allow update to continue
        return book! unless booked? && on_calendar?

        calendar_update(call_if: true) do
          calendar.update(google_calendar_event_id, calendar_hash)
        end
      rescue StandardError => e
        Bugsnag.notify(e)
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

        update(conference_id_cache: info[:id])
        info[:id]
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

        store_conference_details(state: state)
        calendar.update(google_calendar_event_id, calendar_hash)
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
        hash[:conference] = { id: :new } if booked? && online && conference_id.nil?

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
        %i[
          event_type_id start_at length_h length_m sessions all_day description location_id online
        ].any? { |field| send("will_save_change_to_#{field}?") }
      end

      def store_calendar_details(response)
        update(google_calendar_event_id: response&.id, google_calendar_link: response&.html_link)
      end

      def store_conference_details(state: true)
        clear_attributes = { online: false, conference_id_cache: nil, link_override: nil }
        attributes = state ? { online: true } : clear_attributes
        update(attributes)
      end

      def calendar_update(call_if: true, set_to: nil)
        Rails.logger.silence do
          response = yield if call_if
          set = { response: response, nil: nil }[set_to]
          store_calendar_details(set) if set_to.present?
          conference!(state: online)
        end
      end
    end
  end
end
