# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'
require 'active_storage'
require 'csv'
require 'differ/string'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Bps
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.exceptions_app = routes

    config.middleware.use Rack::Deflater

    config.time_zone = 'Eastern Time (US & Canada)'
    config.active_record.default_timezone = :local
    config.active_record.time_zone_aware_types = [:datetime]

    config.to_prepare do
      Devise::Mailer.layout 'mailer'
    end

    unless File.exist?(Rails.application.secrets[:cf_private_key_path])
      k = File.open(Rails.application.secrets[:cf_private_key_path], 'w+')
      File.chmod(0600, k)
      k.write(ENV['CLOUDFRONT_PRIVATE_KEY'])
      k.close
    end
  end
end
