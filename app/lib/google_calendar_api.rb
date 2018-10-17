# frozen_string_literal: true

require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'

class GoogleCalendarAPI
  include GoogleCalendarAPI::ClearTestCalendar

  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
  LAST_TOKEN_PATH = "#{Rails.root}/tmp/run/last_page_token"

  def initialize(auth: false)
    self.authorize! if auth
  end

  def authorize!(refresh: false)
    service.authorization = authorize(refresh: refresh)
  end

  def create(calendar_id, event_options = {})
    service.insert_event(
      calendar_id, event(event_options), conference_data_version: 1
    )
  end

  def list(calendar_id, max_results: 2500, page_token: nil)
    service.list_events(
      calendar_id, max_results: max_results, page_token: page_token
    )
  end

  def get(calendar_id, event_id)
    service.get_event(calendar_id, event_id)
  end

  def update(calendar_id, event_id, event_options = {})
    service.update_event(
      calendar_id, event_id, event(event_options)
    )
  end

  def delete(calendar_id, event_id)
    service.delete_event(calendar_id, event_id)
  end

  def permit(calendar, user)
    rule = Google::Apis::CalendarV3::AclRule.new(
      scope: { type: 'user', value: user.email },
      role: 'writer'
    )

    result = service.insert_acl(calendar, rule)
    user.update(calendar_rule_id: result.id)
  end

  def unpermit(calendar, user)
    service.delete_acl(calendar, user.calendar_rule_id)
  end

  private

  def authorize(refresh: false)
    @user_id = 'default'
    @credentials = authorizer.get_credentials(@user_id)
    return @credentials unless @credentials.nil? || refresh

    @url = authorizer.get_authorization_url(base_url: OOB_URI)
    puts 'Open to authorize:', @url
    @code = gets
    @credentials = authorizer.get_and_store_credentials_from_code(
      user_id: @user_id, code: @code, base_url: OOB_URI
    )
  end

  def authorizer
    @authorizer ||= Google::Auth::UserAuthorizer.new(
      Google::Auth::ClientId.from_hash(
        JSON.parse(File.read('config/keys/google_calendar_api_client.json'))
      ),
      Google::Apis::CalendarV3::AUTH_CALENDAR,
      Google::Auth::Stores::FileTokenStore.new(
        file: 'config/keys/google_calendar_token.yaml'
      )
    )
  end

  def service
    @service ||= Google::Apis::CalendarV3::CalendarService.new
  end

  def event(event_options)
    event_options.assert_valid_keys(valid_event_keys)
    event_options[:start] = date(event_options[:start])
    event_options[:end] = date(event_options[:end])

    Google::Apis::CalendarV3::Event.new(event_options.reject { |_, v| v.nil? })
  end

  def valid_event_keys
    %i[
      summary start end description location recurrence conference_data
      conference_data_version
    ]
  end

  def date(date)
    key = date&.is_a?(String) ? :date : :date_time
    Google::Apis::CalendarV3::EventDateTime.new(
      key => date, time_zone: 'America/Detroit'
    )
  end
end
