# frozen_string_literal: true

module Concerns::Event::Calendar
  def book!
    response = calendar.create(calendar_id, calendar_hash)
    store_calendar_details(response)
  end

  def unbook!
    return if google_calendar_event_id.blank?

    calendar.delete(calendar_id, google_calendar_event_id)
    store_calendar_details(nil)
  end

  def refresh_calendar!
    return if google_calendar_event_id.blank?

    calendar.update(calendar_id, google_calendar_event_id, calendar_hash)
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

  def calendar_id
    id = if category.in?(%w[course seminar])
           ENV['GOOGLE_CALENDAR_ID_EDUC']
         else
           ENV['GOOGLE_CALENDAR_ID_GEN']
         end

    Rails.env.production? ? id : ENV['GOOGLE_CALENDAR_ID_TEST']
  end

  def calendar_hash
    {
      start: start_at.to_datetime,
      end: start_at.to_datetime + (length.hour.hours || 1.hour),
      summary: calendar_summary,
      description: calendar_description,
      location: location&.one_line,
      recurrence: recurrence
    }
  end

  def recurrence
    ["RRULE:FREQ=WEEKLY;COUNT=#{sessions}"] if sessions.present?
  end

  def calendar_summary
    if category == 'course'
      "Course: #{event_type.display_title}"
    elsif category == 'seminar'
      "Seminar: #{event_type.display_title}"
    else
      event_type.display_title
    end
  end

  def calendar_description
    description.to_s +
      "\n\n#{link}" \
      "\n\n*** Booked automatically by #{ENV['DOMAIN']} ***"
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
