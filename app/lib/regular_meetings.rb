# frozen_string_literal: true

class RegularMeetings
  def book_regular_meetings!
    calendar.create(calendar_id, membership)
    calendar.create(calendar_id, excom)
  end

private

  def calendar
    Event.last.send(:calendar)
  end

  def calendar_id
    Event.includes(:event_type).where(event_types: { event_category: 'meeting' })
         .last.send(:calendar_id)
  end

  def membership
    {
      start: Time.strptime('2018/01/09 18:00 EST', '%Y/%m/%d %H:%M %Z').to_datetime,
      end: Time.strptime('2018/01/09 21:00 EST', '%Y/%m/%d %H:%M %Z').to_datetime,
      summary: 'Membership Meeting',
      description: membership_description,
      location: "Kerby's Koney Island, 5407 Crooks Rd, Troy, MI 48098, USA",
      recurrence: ['RRULE:FREQ=MONTHLY;BYMONTH=1,2,3,4,5,9,10,11,12;BYDAY=2TU'],
      conference_data_version: 1,
      conference_data: Google::Apis::CalendarV3::ConferenceData.new(**membership_meet)
    }
  end

  def membership_description
    "Monthly general membership meeting.\n\n" \
    'If you would like to join this meeting remotely, please notify a bridge ' \
    'officer ahead of time.'
  end

  def membership_meet
    meet(ENV['MEMBERSHIP_MEET_ID'], ENV['MEMBERSHIP_MEET_SIGNATURE'])
  end

  def excom
    {
      start: Time.strptime('2018/01/02 18:00 EST', '%Y/%m/%d %H:%M %Z').to_datetime,
      end: Time.strptime('2018/01/02 21:30 EST', '%Y/%m/%d %H:%M %Z').to_datetime,
      summary: 'Executive Committee Meeting',
      description: excom_description,
      location: "Kerby's Koney Island, 5407 Crooks Rd, Troy, MI 48098, USA",
      recurrence: ['RRULE:FREQ=MONTHLY;BYMONTH=1,2,3,4,5,6,9,10,11,12;BYDAY=1TU'],
      conference_data: Google::Apis::CalendarV3::ConferenceData.new(**excom_meet)
    }
  end

  def excom_description
    "Monthly meeting of the Executive Committee.\n\n" \
    "All members are welcome to attend!\n\n" \
    'If you would like to join this meeting remotely, please notify a bridge ' \
    'officer ahead of time.'
  end

  def excom_meet
    meet(ENV['EXCOM_MEET_ID'], ENV['EXCOM_MEET_SIGNATURE'])
  end

  def meet(conf_id, signature)
    {
      conference_id: conf_id,
      conference_solution: meet_solution,
      entry_points: meet_entry(conf_id),
      signature: signature
    }
  end

  def meet_solution
    Google::Apis::CalendarV3::ConferenceSolution.new(
      icon_uri: ENV['GOOGLE_CALENDAR_ICON_URI'],
      key: Google::Apis::CalendarV3::ConferenceSolutionKey.new(type: 'hangoutsMeet'),
      name: 'Hangouts Meet'
    )
  end

  def meet_entry(conf_id)
    [
      Google::Apis::CalendarV3::EntryPoint.new(
        entry_point_type: 'video',
        label: "meet.google.com/#{conf_id}",
        uri: "https://meet.google.com/#{conf_id}"
      )
    ]
  end
end
