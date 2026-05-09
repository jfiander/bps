# frozen_string_literal: true

namespace :server do
  desc 'Ping the server to start Passenger'
  task :ping do
    on release_roles :all do
      info 'Pinging server...'
      `curl -I https://www.bpsd9.org 2>&1 /dev/null`
    end
  end

  before 'deploy:finished', 'server:ping'
  after 'passenger:restart', 'server:ping'
end
