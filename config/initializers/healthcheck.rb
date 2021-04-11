# frozen_string_literal: true

Healthcheck.configure do |config|
  config.success = 200
  config.error = 503
  config.verbose = true
  config.route = '/health'
  config.method = :get

  config.add_check :database, -> { ActiveRecord::Base.connection.execute('SELECT 1') }
  config.add_check :migrations, -> { ActiveRecord::Migration.check_pending! }
  # config.add_check :example, -> { raise 'This fails a health check' }
end
