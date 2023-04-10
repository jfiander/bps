# frozen_string_literal: true

source 'https://rubygems.org'
ruby '3.1.3'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'rails',               '~> 6.1.7', '>= 6.1.7.3'

gem 'puma',                '~> 4.3'

gem 'mysql2',              '~> 0.5'

# Rails Plugins
gem 'coffee-rails',        '~> 4.2'
gem 'jbuilder',            '~> 2.5'
gem 'jquery-rails',        '~> 4.3'
gem 'jquery-ui-rails',     '~> 6.0'
gem 'rack-cors',           '~> 1.0'
gem 'sass-rails',          '~> 5.0'
gem 'uglifier',            '~> 4.1'

gem 'figaro',              '~> 1.2'

# Model Behavior
gem 'kt-paperclip',        '~> 7.1'
gem 'paper_trail',         '~> 11.0'
gem 'paranoia',            '~> 2.4'

# APIs and External Services
gem 'aws-sdk-cloudfront',  '~> 1.61'
gem 'aws-sdk-rails',       '~> 3.6'
gem 'aws-sdk-s3',          '~> 1.111'
gem 'aws-sdk-ses',         '~> 1.45'
gem 'aws-sdk-sns',         '~> 1.50'
gem 'bps-google-api',      '~> 0.6', '>= 0.6.1'
gem 'braintree',           '~> 3.3'
gem 'geocoder',            '~> 1.6'
gem 'rushover',            '~> 0.3'
gem 'slack-notifier',      '~> 2.3'

gem 'slack-notification',  '~> 0.1', '>= 0.1.11'

# General Functionality
gem 'devise',              '~> 4.7'
gem 'devise_invitable',    '~> 1.7'
gem 'encrypted-keystore',  '>= 0.0.6'
gem 'exp_retry',           '>= 0.0.13'
gem 'google-protobuf',     '~> 3.21'
gem 'jwt',                 '~> 2.2'
gem 'lograge',             '~> 0.12'
gem 'matrix',              '~> 0.4'
gem 'prawn',               '~> 2.2'
gem 'prawn-svg',           '~> 0.28'
gem 'ruby-progressbar',    '~> 1.10'
gem 'sanitize_email',      '~> 1.2'

# # Background Tasks
# gem 'redis',             '~> 3.0'
gem 'sidekiq',             '~> 7.0'

# View Management
gem 'fa_rails',            '~> 0.1', '>= 0.1.31'
gem 'inline_svg',          '~> 1.7'
gem 'nested_form_fields',  '~> 0.8'
gem 'redcarpet',           '~> 3.5'
gem 'slim',                '~> 3.0'
gem 'usps_flags',          '~> 0.6', '>= 0.6.3'
gem 'usps_flags-burgees',  '~> 0.1', '>= 0.1.3'
gem 'usps_flags-grades',   '~> 0.1', '>= 0.1.5'

# Logging
gem 'bugsnag',             '~> 6.1'

# Inspection
gem 'differ',              '~> 0.1'

# Manual Upgrades
gem 'nokogiri',            '>= 1.13.2'

group :development do
  gem 'capistrano',            '~> 3.16'
  gem 'capistrano-bundler',    '~> 2.0'
  gem 'capistrano-figaro-yml', '~> 1.0'
  gem 'capistrano-passenger',  '~> 0.2'
  gem 'capistrano-rails',      '~> 1.6'
  gem 'capistrano-rvm',        '~> 0.1'

  gem 'guard',                 '~> 2.18'
  gem 'guard-rspec',           '~> 4.7'
  gem 'guard-rubocop',         '~> 1.5'
end

group :development, :test do
  gem 'brakeman',                 '~> 4.3'
  gem 'dotenv',                   '~> 2.7'

  # Specs
  gem 'database_cleaner',         '~> 1.0'
  gem 'factory_bot_rails',        '~> 6.2'
  gem 'fuubar',                   '~> 2.0'
  gem 'rails-controller-testing', '~> 1.0'
  gem 'rspec-rails',              '~> 6.0'
  gem 'simplecov',                '~> 0.22'

  # Rubocop
  gem 'rubocop',                  '>= 1.48'
  gem 'rubocop-rails',            '~> 2.18'
  gem 'rubocop-rspec',            '~> 2.19'

  # Debugging
  gem 'listen',                   '~> 3.1'
end
