# frozen_string_literal: true

source 'https://rubygems.org'
ruby '3.3.11'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'rails',               '~> 8.0.0'

gem 'puma',                '~> 5.6'

gem 'mysql2',              '~> 0.5.6'

# Rails Plugins
gem 'coffee-rails',        '~> 4.2'
gem 'jbuilder',            '~> 2.13'
gem 'jquery-rails',        '~> 4.3'
gem 'jquery-ui-rails',     '~> 6.0'
gem 'rack-cors',           '~> 1.0'
gem 'sass-rails',          '~> 6.0'
gem 'terser',              '~> 1.2'

gem 'figaro',              '~> 1.2.0'

gem 'recaptcha'

# Model Behavior
gem 'kt-paperclip',        '~> 7.2'
gem 'paper_trail',         '~> 15.1'
gem 'paranoia',            '~> 3.0'

# APIs and External Services
gem 'aws-sdk-cloudfront', '~> 1.61'
gem 'aws-sdk-rails',       '~> 4.1'
gem 'aws-sdk-s3',          '~> 1.111'
gem 'aws-sdk-ses',         '~> 1.45'
gem 'aws-sdk-sns',         '~> 1.50'
gem 'bps-google-api',      '~> 0.7.0'
gem 'braintree',           '~> 4.26'
gem 'geocoder',            '~> 1.6.1'
gem 'rushover',            '~> 0.3.0'
gem 'sendgrid-ruby',       '~> 5.2'
gem 'slack-notifier',      '~> 2.3'

gem 'slack-notification',  '~> 0.1.11'

# General Functionality
gem 'devise',              '~> 4.7'
gem 'devise_invitable',    '~> 2.0', '>= 2.0.9'
gem 'encrypted-keystore',  '~> 0.0.6'
gem 'exp_retry',           '~> 0.0.13'
gem 'google-protobuf',     '~> 3.21'
gem 'jwt',                 '~> 2.2.3'
gem 'lograge'
gem 'pdf-reader',          '~> 2.10.0'
gem 'prawn',               '~> 2.5'
gem 'prawn-svg',           '~> 0.28.0'
gem 'ruby-progressbar',    '~> 1.10'
gem 'sanitize_email',      '~> 1.2'

# # Background Tasks
# gem 'redis',             '~> 3.0'
gem 'sidekiq',             '~> 7.1'

# View Management
gem 'fa_rails',            '~> 0.2.0'
gem 'inline_svg',          '~> 1.7.2'
gem 'nested_form_fields',  '~> 0.8.2'
gem 'redcarpet',           '~> 3.5.1'
gem 'slim',                '~> 3.0.6'
gem 'usps_flags',          '~> 0.7.1'
gem 'usps_flags-burgees',  '~> 0.2.0'
gem 'usps_flags-grades',   '~> 0.2.0'

# Logging
gem 'bugsnag',             '~> 6.1.0'

# Inspection
gem 'awesome_print',       '~> 1.8.0'
gem 'differ',              '~> 0.1.2'

# Manual Upgrades
# fileutils is a Ruby default gem (3.3 ships 1.7.2). Don't pin it — an
# explicit `~> 1.4.1` here forces bundler to activate the older copy and
# clashes with the preloaded default at app boot under Passenger.
# Transitive constraints (bps-google-api, encrypted-keystore) are
# satisfied by anything in the 1.x line.
gem 'loofah',              '>= 2.21'
gem 'nokogiri',            '>= 1.14.3'
gem 'rubyzip',             '>= 1.3.0'
gem 'sinatra',             '~> 2.2.3'

group :development do
  gem 'capistrano',            '~> 3.16.0'
  gem 'capistrano-bundler',    '~> 2.0.1'
  # Upstream is unmaintained on rubygems; pin to chouandy's fork commit
  # that exams uses, which works against modern Capistrano + figaro.
  gem 'capistrano-figaro-yml', github: 'chouandy/capistrano-figaro-yml', ref: 'f43cf2238343d93bfda7526b28268908ea895c1f'
  gem 'capistrano-passenger',  '~> 0.2.0'
  gem 'capistrano-rails',      '~> 1.6.1'
  gem 'capistrano-rbenv',      '~> 2.2'

  gem 'bcrypt_pbkdf'
  gem 'ed25519'

  gem 'guard',                 '~> 2.18'
  gem 'guard-rspec',           '~> 4.7'
  gem 'guard-rubocop',         '~> 1.5'
end

group :development, :test do
  gem 'dotenv', '~> 2.7.6'

  # Specs
  gem 'database_cleaner-active_record', '~> 2.2'
  gem 'factory_bot_rails',        '~> 6.2'
  gem 'fuubar',                   '~> 2'
  gem 'rails-controller-testing', '~> 1'
  gem 'rspec-rails',              '~> 6.1'
  gem 'simplecov',                '~> 0'

  # Rubocop
  gem 'rubocop',                  '>= 1.48'
  gem 'rubocop-rails',            '~> 2.18'
  gem 'rubocop-rspec',            '~> 2.19'

  gem 'brakeman',                 '~> 4.3'

  # Debugging
  # gem 'bullet',                   '~> 5.7.0'
  gem 'listen',                   '~> 3.8'
end
