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

module BPS
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.exceptions_app = routes

    config.middleware.use Rack::Deflater

    config.time_zone = 'Eastern Time (US & Canada)'
    config.active_record.default_timezone = :local
    config.active_record.time_zone_aware_types = %i[datetime time]

    config.to_prepare { Devise::Mailer.layout('mailer') }

    # Ensure working temp dir exists
    FileUtils.mkdir_p("#{Rails.root}/tmp/run")

    def deployed?
      Rails.env.production? || Rails.env.staging?
    end
  end
end

Dotenv.load unless BPS::Application.deployed?

require 'redcarpet/render_strip'

require_relative '../app/lib/proto/user_update_pb'
require_relative '../app/lib/proto/proto_extensions'
