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

    config.load_defaults 7.1

    # Rails 7.1 defaults that must be set in application.rb (not in an initializer):
    config.active_support.cache_format_version = 7.1
    config.add_autoload_paths_to_load_path = false

    # Mailer previews live under app/mailers/previews and would be picked up
    # by zeitwerk's eager-load. Tell rails the preview path explicitly and
    # ignore it for autoloading.
    config.action_mailer.preview_path = "#{root}/app/mailers/previews"
    Rails.autoloaders.main.ignore("#{root}/app/mailers/previews")

    config.exceptions_app = routes

    config.middleware.use Rack::Deflater

    config.active_job.queue_adapter = :sidekiq
    # config.active_job.queue_name_prefix = Rails.env
    # config.active_job.queue_name_delimiter = '.'

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
