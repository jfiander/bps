# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'
require 'csv'
require 'differ/string'
require 'fa'
require 'google_api'
require 'encrypted_keystore'
require 'slack_notification'

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
    config.active_record.time_zone_aware_types = %i[datetime time]

    config.active_record.sqlite3.represent_boolean_as_integer = true

    config.to_prepare { Devise::Mailer.layout('mailer') }

    # Ensure working temp dir exists
    FileUtils.mkdir_p("#{Rails.root}/tmp/run")
  end
end

Dotenv.load unless Rails.env.production? # development and test

require 'redcarpet/render_strip'
