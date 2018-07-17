source 'https://rubygems.org'
ruby '2.4.2'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'rails',               '~> 5.2'

gem 'puma',                '~> 3.12'

# Rails Plugins
gem 'activestorage',       '~> 5.2.0'
gem 'coffee-rails',        '~> 4.2'
gem 'jbuilder',            '~> 2.5'
gem 'jquery-rails',        '~> 4.3'
gem 'jquery-ui-rails',     '~> 6.0'
gem 'rack-cors',           '~> 1.0'
gem 'sass-rails',          '~> 5.0'
gem 'uglifier',            '~> 1.3.0'

# Model Behavior
gem 'paper_trail',         '~> 9.2.0'
gem 'paranoia',            '~> 2.4.1'
gem 'sanitize_email',      '~> 1.2'

# App Functionality
gem 'aws-sdk',             '~> 2.11.89'
gem 'aws-sdk-rails',       '~> 1.0'
gem 'devise',              '~> 4.4.3'
gem 'devise_invitable',    '~> 1.7'
gem 'google-api-client',   '~> 0.23.4'
gem 'mini_magick',         '~> 4.8'
gem 'paperclip',           '~> 5.3.0'
gem 'prawn',               '~> 2.2.2'
# gem 'redis',             '~> 3.0'
gem 'sendgrid-ruby',       '~> 5.2'
# gem 'sidekiq',           '~> 5.0'
gem 'slack-notifier',      '~> 2.3'

# View Management
gem 'inline_svg',          '~> 1.3.0'
gem 'nested_form_fields',  '~> 0.8.2'
gem 'redcarpet',           '~> 3.4.0'
gem 'slim',                '~> 3.0.6'
gem 'usps_flags',          '~> 0.3.20'
gem 'usps_flags-burgees',  '~> 0.0.19'
gem 'usps_flags-grades',   '~> 0.0.4'

# Logging
gem 'bugsnag',             '~> 6.1.0'
gem 'newrelic_rpm',        '~> 5.0.0.342'

# Inspection
gem 'awesome_print',       '~> 1.8.0'
gem 'differ',              '~> 0.1.2'

# Manual Upgrades
gem 'sinatra',             '~> 2.0.3'

group :production do
  gem 'pg',                '~> 0.18.4'
  gem 'rails_12factor',    '~> 0.0.3'
end

group :development, :test do
  gem 'sqlite3',           '~> 1.3.11'

  # Specs
  gem 'database_cleaner',  '~> 1.6.2'
  gem 'factory_bot_rails', '~> 4.8.2'
  gem 'rspec-rails',       '~> 3.7.1'
  gem 'simplecov',         '~> 0.15.1'

  # Debugging
  gem 'bullet',            '~> 5.7.0'
  gem 'listen',            '~> 3.1.5'
end
