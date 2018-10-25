# frozen_string_literal: true

module Concerns::Event::Calendar
  extend ActiveSupport::Concern

  def book!
    return if booked?

    response = calendar_retry.call { calendar.create(calendar_id, calendar_hash) }
    store_calendar_details(response)
  rescue StandardError => e
    Bugsnag.notify(e)
  end

  def unbook!
    return unless booked?

    calendar_retry.call { calendar.delete(calendar_id, google_calendar_event_id) } if on_calendar?
    store_calendar_details(nil)
  rescue StandardError => e
    Bugsnag.notify(e)
  end

  def refresh_calendar!
    return unless booked?
    return book! unless on_calendar?

    calendar_retry.call { calendar.update(calendar_id, google_calendar_event_id, calendar_hash) }
  rescue StandardError => e
    Bugsnag.notify(e)
  end

  def booked?
    google_calendar_event_id.present?
  end

  def on_calendar?
    event = calendar.get(calendar_id, google_calendar_event_id)
    event.present? && event.status != 'cancelled'
  rescue Google::Apis::ClientError, 'notFound: Not Found'
    false
  end

private

  def calendar
    @calendar ||= GoogleCalendarAPI.new(auth: true)
  end

  def calendar_id(production: false)
    if production || ENV['ASSET_ENVIRONMENT'] == 'production'
      production_calendar_id
    else
      ENV['GOOGLE_CALENDAR_ID_TEST']
    end
  end

  def production_calendar_id
    return ENV['GOOGLE_CALENDAR_ID_EDUC'] if category.in?(%w[course seminar])

    ENV['GOOGLE_CALENDAR_ID_GEN']
  end

  def calendar_hash
    {
      start: start_date, end: end_date, recurrence: recurrence,
      summary: calendar_summary, description: calendar_description,
      location: location&.one_line
    }
  end

  def recurrence
    ["RRULE:FREQ=#{repeat_pattern};COUNT=#{sessions}"] unless no_recurrence?
  end

  def no_recurrence?
    all_day || !(sessions.present? && sessions > 1)
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
    hours = length.strftime('%H').to_i
    minutes = length.strftime('%M').to_i

    start_at.to_datetime + (hours || 1).hours + (minutes || 0).minutes
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
    %i[event_type_id start_at length sessions all_day description location_id].any? do |field|
      send("will_save_change_to_#{field}?")
    end
  end

  def store_calendar_details(response)
    update(google_calendar_event_id: response&.id, google_calendar_link: response&.html_link)
  end

  def calendar_retry
    ExpRetry.new(exception: Google::Apis::RateLimitError, retries: 6)
  end
end
