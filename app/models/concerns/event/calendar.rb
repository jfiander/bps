# frozen_string_literal: true

module Concerns::Event::Calendar
  def book!
    response = calendar.create(calendar_id, calendar_hash)
    update(google_calendar_event_id: response)
  end

  def unbook!
    return if google_calendar_event_id.blank?

    calendar.delete(calendar_id, google_calendar_event_id)
    update(google_calendar_event_id: nil)
  end

  private

  def calendar
    return @calendar unless @calendar.nil?

    @calendar = GoogleCalendarAPI.new
    @calendar.authorize!
    @calendar
  end

  def calendar_id
    if category.in?(%i[course seminar])
      ENV['GOOGLE_CALENDAR_ID_EDUC']
    else
      ENV['GOOGLE_CALENDAR_ID_GEN']
    end
  end

  def calendar_hash
    {
      start: start_at.to_datetime,
      end: start_at.to_datetime + length.hour.hours,
      summary: calendar_summary,
      description: calendar_description,
      location: location&.address&.split(/\R/)&.first
    }
  end

  def calendar_summary
    if category == :course
      "Course: #{event_type.display_title}"
    elsif category == :seminar
      "Seminar: #{event_type.display_title}"
    else
      event_type.display_title
    end
  end

  def calendar_description
    "#{description}\n\n*** Booked automatically by #{ENV['DOMAIN']} ***"
  end
end
