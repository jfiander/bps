# frozen_string_literal: true

require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'

class GoogleCalendarAPI
  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'

  def authorize!
    service.authorization = authorize
  end

  def create(calendar, event_options = {})
    event_options.assert_valid_keys(%i[summary start end description location])
    event_options[:start] = datetime(event_options[:start])
    event_options[:end] = datetime(event_options[:end])

    response = service.insert_event(calendar, event(event_options))

    response.id
  end

  def delete(calendar, event_id)
    service.delete_event(calendar, event_id)
  end

  private

  def authorize
    @user_id = 'default'
    File.open('config/keys/google_calendar_token.yaml', 'w+') do |f|
      f.write("---\ndefault: '")
      f.write(ENV['GOOGLE_CALENDAR_TOKEN'])
      f.write("'\n")
    end
    @credentials = authorizer.get_credentials(@user_id)
    return @credentials unless @credentials.nil?

    @url = authorizer.get_authorization_url(base_url: OOB_URI)
    puts 'Open to authorize:', @url
    @code = gets
    @credentials = authorizer.get_and_store_credentials_from_code(
      user_id: @user_id, code: @code, base_url: OOB_URI
    )
  end

  def authorizer
    @authorizer ||= Google::Auth::UserAuthorizer.new(
      Google::Auth::ClientId.from_hash(JSON.parse(ENV['GOOGLE_CALENDAR_API_CLIENT'])),
      Google::Apis::CalendarV3::AUTH_CALENDAR,
      Google::Auth::Stores::FileTokenStore.new(file: 'config/keys/google_calendar_token.yaml')
    )
  end

  def service
    @service ||= Google::Apis::CalendarV3::CalendarService.new
  end

  def event(*args)
    Google::Apis::CalendarV3::Event.new(*args)
  end

  def datetime(date)
    Google::Apis::CalendarV3::EventDateTime.new(date_time: date)
  end
end