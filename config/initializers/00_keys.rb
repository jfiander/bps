# frozen_string_literal: true

# Creates key files from environment variables
def self.store_key(path, key = nil, overwrite: true)
  return if File.exist?(path) && !overwrite

  File.open(path, 'w+') do |f|
    File.chmod(0600, f)
    block_given? ? yield(f) : f.write(key)
  end
end

store_key(
  Rails.application.secrets[:cf_private_key_path],
  ENV['CLOUDFRONT_PRIVATE_KEY'],
  overwrite: false
)

store_key('config/keys/google_calendar_token.yaml') do |f|
  f.write("---\ndefault: '")
  f.write(ENV['GOOGLE_CALENDAR_TOKEN'])
  f.write("'\n")
end

store_key('config/keys/google_calendar_api_client.json') do |f|
  f.write('{"installed":{"client_id":"')
  f.write(ENV['GOOGLE_CLIENT_ID'])
  f.write('","project_id":"charming-scarab-208718",')
  f.write('"auth_uri":"https://accounts.google.com/o/oauth2/auth",')
  f.write('"token_uri":"https://accounts.google.com/o/oauth2/token",')
  f.write('"auth_provider_x509_cert_url":')
  f.write('"https://www.googleapis.com/oauth2/v1/certs",')
  f.write('"client_secret":"')
  f.write(ENV['GOOGLE_CLIENT_SECRET'])
  f.write('","redirect_uris":["urn:ietf:wg:oauth:2.0:oob",')
  f.write('"http://localhost"]}}')
end

store_key('config/keys/google_calendar_token.yaml') do |f|
  f.write("---\n")
  f.write("default: '")
  f.write('{"client_id":"')
  f.write(ENV['GOOGLE_CLIENT_ID'])
  f.write('","access_token":"')
  f.write(ENV['GOOGLE_ACCESS_TOKEN'])
  f.write('","refresh_token":"')
  f.write(ENV['GOOGLE_REFRESH_TOKEN'])
  f.write('","scope":["https://www.googleapis.com/auth/calendar"],')
  f.write('"expiration_time_millis":1530304405000}')
  f.write("'\n")
end