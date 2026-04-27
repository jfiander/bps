# frozen_string_literal: true

Bugsnag.configure do |config|
  config.api_key = ENV['BUGSNAG_KEY']
  config.enabled_release_stages = %w[production staging]
end
