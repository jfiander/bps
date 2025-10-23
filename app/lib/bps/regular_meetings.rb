# frozen_string_literal: true

module BPS
  class RegularMeetings
    def book!(skip_membership: false, skip_excom: false)
      calendar.create(membership) unless skip_membership
      calendar.create(excom) unless skip_excom
    end

  private

    def calendar
      @calendar ||= GoogleAPI::Configured::Calendar.new(calendar_id)
    end

    def calendar_id
      Event.for_category('meeting').last.send(:calendar_id)
    end

    def months_except(*except)
      (1..12).to_a - except
    end

    def membership
      meeting_hash(
        summary: 'Membership Meeting', description: membership_description,
        months: months_except(6, 7, 8), date: '09', week: '2', conference: {
          conference: { id: ENV['MEMBERSHIP_MEET_ID'], signature: ENV['MEMBERSHIP_MEET_SIGNATURE'] }
        }
      )
    end

    def membership_description
      "Monthly general membership meeting.\n\n" \
        "All members and their guests are welcome to attend!\n\n" \
        'If you would like to join this meeting remotely, ' \
        'please notify a bridge officer ahead of time.'
    end

    def excom
      meeting_hash(
        summary: 'Executive Committee Meeting', description: excom_description,
        months: months_except(7, 8), date: '02', week: '1', conference: {
          conference: { id: ENV['EXCOM_MEET_ID'], signature: ENV['EXCOM_MEET_SIGNATURE'] }
        }
      )
    end

    def excom_description
      "Monthly meeting of the Executive Committee.\n\n" \
        "All members are welcome to attend!\n\n" \
        'If you would like to join this meeting remotely, ' \
        'please notify a bridge officer ahead of time.'
    end

    def meeting_hash(**options)
      months = options[:months].join(',')

      {
        start: start_time(options[:date]),
        end: end_time(options[:date]),
        summary: options[:summary], description: options[:description],
        location: "Kerby's Koney Island, 5407 Crooks Rd, Troy, MI 48098, USA",
        recurrence: ["RRULE:FREQ=MONTHLY;BYMONTH=#{months};BYDAY=#{options[:week]}TU"],
        conference: options[:conference]
      }
    end

    def start_time(date)
      Time.strptime("2025/11/#{date} 18:00 EST", '%Y/%m/%d %H:%M %Z').to_datetime
    end

    def end_time(date)
      Time.strptime("2025/11/#{date} 21:00 EST", '%Y/%m/%d %H:%M %Z').to_datetime
    end
  end
end
