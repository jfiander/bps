# frozen_string_literal: true

module GoogleAPI
  class Base
    OOB_URI ||= 'urn:ietf:wg:oauth:2.0:oob'
    AUTH_SCOPES ||= [
      Google::Apis::AdminDirectoryV1::AUTH_ADMIN_DIRECTORY_GROUP,
      Google::Apis::CalendarV3::AUTH_CALENDAR
    ].freeze

    def initialize(auth: false)
      self.authorize! if auth
    end

    def authorize!(refresh: false, reveal: false)
      auth = authorize(refresh: refresh)
      service.authorization = auth
      return true unless reveal

      [auth, auth_keys(auth)]
    end

  private

    def service
      raise 'No service class defined.' unless defined?(service_class)

      @service ||= service_class.new
    end

    def authorize(user_id = 'default', refresh: false)
      @credentials = authorizer.get_credentials(user_id)
      return @credentials unless @credentials.nil? || refresh

      @credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id, code: request_authorization, base_url: OOB_URI
      )
    end

    def request_authorization
      url = authorizer.get_authorization_url(base_url: OOB_URI)
      puts("Open this URL to authorize:\n", url)
      print("\nResponse code: ")
      gets
    end

    def authorizer
      @authorizer ||= Google::Auth::UserAuthorizer.new(auth_client_id, AUTH_SCOPES, auth_token_store)
    end

    def auth_client_id
      Google::Auth::ClientId.from_hash(JSON.parse(File.read('config/keys/google_api_client.json')))
    end

    def auth_token_store
      Google::Auth::Stores::FileTokenStore.new(file: 'config/keys/google_token.yaml')
    end

    def auth_keys(auth)
      {
        GOOGLE_CLIENT_ID: auth.client_id, GOOGLE_CLIENT_SECRET: auth.client_secret,
        GOOGLE_ACCESS_TOKEN: auth.access_token, GOOGLE_REFRESH_TOKEN: auth.refresh_token,
        GOOGLE_AUTH_SCOPE: auth.scope, GOOGLE_AUTH_EXP: expires_milli(auth.as_json['expires_at'])
      }
    end

    def expires_milli(time)
      DateTime.strptime(time, '%Y-%m-%dT%H:%M:%S.%L%:z').to_i * 1000
    end
  end
end
