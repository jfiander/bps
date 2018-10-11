# frozen_string_literal: true

module Concerns::Event::Calendar
  def book!
    return if booked?

    response = calendar.create(calendar_id, calendar_hash)
    store_calendar_details(response)
  rescue StandardError => e
    Bugsnag.notify(e)
  end

  def unbook!
    return unless booked?

    calendar.delete(calendar_id, google_calendar_event_id)
    store_calendar_details(nil)
  rescue StandardError => e
    Bugsnag.notify(e)
  end

  def refresh_calendar!
    return unless booked?

    calendar.update(calendar_id, google_calendar_event_id, calendar_hash)
  rescue StandardError => e
    Bugsnag.notify(e)
  end

  def booked?
    google_calendar_event_id.present?
  end

  private

  def calendar
    return @calendar unless @calendar.nil?

    @calendar = GoogleCalendarAPI.new
    @calendar.authorize!
    @calendar
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
      start: start_date(all_day: all_day),
      end: end_date(all_day: all_day),
      summary: calendar_summary,
      description: calendar_description,
      location: location&.one_line,
      recurrence: recurrence(all_day: all_day)
    }
  end

  def recurrence(all_day: false)
    return unless sessions.present?

    ["RRULE:FREQ=#{repeat_pattern};COUNT=#{sessions}"] unless all_day
  end

  def start_date(all_day: false)
    return start_at.to_datetime unless all_day

    start_at.to_datetime.strftime('%Y-%m-%d')
  end

  def end_date(all_day: false)
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

    if category == 'course'
      "Course: #{event_type.display_title}"
    elsif category == 'seminar'
      "Seminar: #{event_type.display_title}"
    else
      event_type.display_title
    end
  end

  def calendar_description
    Redcarpet::Markdown.new(Redcarpet::Render::StripDown).render(
      description.to_s
    ).gsub("\n", "\n\n") +
      "\n\n#{link}\n\n*** Booked automatically by #{ENV['DOMAIN']} ***"
  end

  def calendar_details_updated?
    will_save_change_to_event_type_id? ||
      will_save_change_to_start_at? ||
      will_save_change_to_length? ||
      will_save_change_to_sessions? ||
      will_save_change_to_description? ||
      will_save_change_to_location_id?
  end

  def store_calendar_details(response)
    update(
      google_calendar_event_id: response&.id,
      google_calendar_link: response&.html_link
    )
  end
end
