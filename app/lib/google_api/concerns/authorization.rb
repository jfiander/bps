# frozen_string_literal: true

module GoogleAPI::Concerns
  module Authorization
    OOB_URI ||= 'urn:ietf:wg:oauth:2.0:oob'
    AUTH_SCOPES ||= [
      Google::Apis::AdminDirectoryV1::AUTH_ADMIN_DIRECTORY_GROUP,
      Google::Apis::CalendarV3::AUTH_CALENDAR
    ].freeze

    def authorize!(refresh: false, reveal: false)
      token_file
      auth = authorize(refresh: refresh)
      service.authorization = auth
      return true unless reveal

      [auth, auth_keys(auth)]
    end

  private

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
      client_id_file
      Google::Auth::ClientId.from_hash(JSON.parse(File.read('config/keys/google_api_client.json')))
    end

    def auth_token_store
      Google::Auth::Stores::FileTokenStore.new(file: 'config/keys/google_token.yaml')
    end

    def auth_keys(auth)
      {
        GOOGLE_CLIENT_ID: auth.client_id, GOOGLE_CLIENT_SECRET: auth.client_secret,
        GOOGLE_ACCESS_TOKEN: auth.access_token, GOOGLE_REFRESH_TOKEN: auth.refresh_token,
        GOOGLE_AUTH_SCOPES: auth.scope, GOOGLE_AUTH_EXP: expires_milli(auth.as_json['expires_at'])
      }
    end

    def expires_milli(time)
      DateTime.strptime(time, '%Y-%m-%dT%H:%M:%S.%L%:z').to_i * 1000
    end

    def store_key(path, key)
      return if File.exist?(path)

      File.open(path, 'w+') do |f|
        File.chmod(0600, f)
        block_given? ? yield(f) : f.write(key)
      end
    end

    def client_id_file
      store_key(
        File.join(Rails.root, 'config/keys/google_api_client.json'),
        <<~KEY
          {"installed":{"client_id":"#{ENV['GOOGLE_CLIENT_ID']}","project_id":"charming-scarab-208718",
          "auth_uri":"https://accounts.google.com/o/oauth2/auth","token_uri":"https://accounts.google.com/o/oauth2/token",
          "auth_provider_x509_cert_url":"https://www.googleapis.com/oauth2/v1/certs","client_secret":"#{ENV['GOOGLE_CLIENT_SECRET']}",
          "redirect_uris":["#{OOB_URI}","http://localhost"]}}
        KEY
      )
    end

    def token_file
      store_key(
        File.join(Rails.root, 'config/keys/google_token.yaml'),
        <<~KEY
          ---
          default: '{"client_id":"#{ENV['GOOGLE_CLIENT_ID']}","access_token":"#{ENV['GOOGLE_ACCESS_TOKEN']}",
          "refresh_token":"#{ENV['GOOGLE_REFRESH_TOKEN']}","scope":[#{scopes}],
          "expiration_time_millis":#{ENV['GOOGLE_AUTH_EXP']}}'
        KEY
      )
    end

    def scopes
      ENV.select { |k, v| k =~ /GOOGLE_AUTH_SCOPE_/ }.values.map { |s| "\"#{s}\"" }.join(',')
    end
  end
end
