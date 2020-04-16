# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.5.1'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'rails',               '~> 5.2.4.2'

gem 'puma',                '~> 3.12'

# Rails Plugins
gem 'coffee-rails',        '~> 4.2'
gem 'jbuilder',            '~> 2.5'
gem 'jquery-rails',        '~> 4.3'
gem 'jquery-ui-rails',     '~> 6.0'
gem 'rack-cors',           '~> 1.0'
gem 'sass-rails',          '~> 5.0'
gem 'uglifier',            '~> 4.1'

# Model Behavior
gem 'paperclip',           '~> 5.3.0'
gem 'paper_trail',         '~> 9.2.0'
gem 'paranoia',            '~> 2.4.1'

# APIs and External Services
gem 'aws-sdk',             '~> 2.11'
gem 'aws-sdk-rails',       '~> 1.0.1'
gem 'braintree',           '~> 2.83'
gem 'bps-google-api',      '~> 0.4.5'
gem 'geocoder',            '~> 1.5.0'
gem 'sendgrid-ruby',       '~> 5.2'
gem 'slack-notifier',      '~> 2.3'

gem 'slack-notification',  '~> 0.1.7'

# General Functionality
gem 'devise',              '~> 4.7.1'
gem 'devise_invitable',    '~> 1.7'
gem 'encrypted-keystore',  '~> 0.0.6'
gem 'exp_retry',           '~> 0.0.13'
gem 'prawn',               '~> 2.2.2'
gem 'prawn-svg',           '~> 0.28.0'
gem 'ruby-progressbar',    '~> 1.10'
gem 'sanitize_email',      '~> 1.2'

# # Background Tasks
# gem 'redis',             '~> 3.0'
# gem 'sidekiq',           '~> 5.0'

# View Management
gem 'fa_rails',            '~> 0.1.22'
gem 'inline_svg',          '~> 1.3.0'
gem 'nested_form_fields',  '~> 0.8.2'
gem 'redcarpet',           '~> 3.4.0'
gem 'slim',                '~> 3.0.6'
gem 'usps_flags',          '~> 0.5.9'
gem 'usps_flags-burgees',  '~> 0.1.3'
gem 'usps_flags-grades',   '~> 0.1.3'

# Logging
gem 'bugsnag',             '~> 6.1.0'
gem 'newrelic_rpm',        '~> 5.0.0.342'

# Inspection
gem 'awesome_print',       '~> 1.8.0'
gem 'differ',              '~> 0.1.2'

# Manual Upgrades
gem 'loofah',              '~> 2.3.1'
gem 'rubyzip',             '>= 1.3.0'
gem 'sinatra',             '~> 2.0.3'

group :production do
  gem 'pg',                '~> 0.18.4'
  gem 'rails_12factor',    '~> 0.0.3'
end

group :development, :test do
  gem 'sqlite3',                  '~> 1.3.11'

  # Specs
  gem 'database_cleaner',         '~> 1.6.2'
  gem 'factory_bot_rails',        '~> 4.8.2'
  gem 'fuubar',                   '~> 2.3.2'
  gem 'rails-controller-testing', '~> 1.0.4'
  gem 'rspec-rails',              '~> 3.7.1'
  gem 'simplecov',                '~> 0.15.1'

  # Rubocop
  gem 'rubocop',                  '~> 0.59'
  gem 'rubocop-performance',      '~> 1.3.0'
  gem 'rubocop-rails_config',     '~> 0.6'
  gem 'rubocop-rspec',            '~> 1.30'

  gem 'brakeman',                 '~> 4.3'

  # Debugging
  gem 'bullet',                   '~> 5.7.0'
  gem 'listen',                   '~> 3.1.5'
end
