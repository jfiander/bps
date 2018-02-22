source 'https://rubygems.org'
ruby '2.4.2'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.0.6'

gem 'puma',               '~> 3.4.0'
gem 'sass-rails',         '~> 5.0'
gem 'uglifier',           '>= 1.3.0'
gem 'coffee-rails',       '~> 4.2'
gem 'jquery-rails',       '~> 4.3.1'
gem 'jquery-ui-rails',    '~> 6.0.1'
# gem 'turbolinks',         '~> 5'
gem 'jbuilder',           '~> 2.5'

# gem 'font-awesome-rails', '~> 4.7.0.2'
gem 'rack-cors',          '~> 1.0.2'

gem 'paranoia', :github => 'rubysherpas/paranoia', :branch => 'rails4'

gem 'sanitize_email',     '~> 1.2.2'

gem 'bugsnag',            '~> 6.1.0'

gem 'aws-sdk',            '~> 2.10.86'
gem 'aws-sdk-rails',      '~> 1.0.1'
gem 'sendgrid-ruby',      '~> 5.2.0'
gem 'paperclip',          '~> 5.1.0'
gem 'mini_magick',        '~> 4.8.0'

gem 'devise',             '~> 4.2.0'
gem 'devise_invitable',   '~> 1.7.2'

gem 'paper_trail',        '~> 8.1.0'

gem 'slim',               '~> 3.0.6'
gem 'inline_svg',         '~> 1.3.0'
gem 'redcarpet',          '~> 3.4.0'

gem 'usps_flags',         '~> 0.3.18'
gem 'usps_flags-burgees', '~> 0.0.18'
gem 'usps_flags-grades',  '~> 0.0.4'

# gem 'redis',              '~> 3.0'
# gem 'sidekiq',            '~> 5.0.5'

gem 'awesome_print'

group :production do
  gem 'pg',               '~> 0.18.4'
  gem 'rails_12factor',   '~> 0.0.3'
end

group :development, :test do
  gem 'sqlite3',          '~> 1.3.11'
  gem 'listen',           '~> 3.1.5'

  gem 'bullet',           '~> 5.7.0'

  gem 'rspec-rails',       '~> 3.7.1'
  gem 'simplecov',         '~> 0.15.1'
  gem 'factory_bot_rails', '~> 4.8.2'
end
