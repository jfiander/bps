# frozen_string_literal: true

Bugsnag.configure do |config|
  config.api_key = ENV['BUGSNAG_KEY']
  config.enabled_release_stages = %w[production staging]

  # Malformed Accept headers / format params from scanners and hack attempts.
  # Rails raises this purely while parsing the value into a MIME type; the
  # request never reaches an action, so these are noise with no security signal.
  config.discard_classes << 'ActionDispatch::Http::MimeNegotiation::InvalidType'
end
