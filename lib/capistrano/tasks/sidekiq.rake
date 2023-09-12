# frozen_string_literal: true

namespace :sidekiq do
  desc 'Restart Sidekiq'
  task :restart do
    on roles(:app) do
      within current_path do
        execute 'sudo service sidekiq restart'
      end
    end
  end

  before 'deploy:finished', 'sidekiq:setup'
  before 'deploy:finished', 'sidekiq:restart'

  desc 'Stop Sidekiq'
  task :stop do
    on roles(:app) do
      within current_path do
        execute 'sudo service sidekiq stop'
      end
    end
  end

  desc 'Start Sidekiq'
  task :start do
    on roles(:app) do
      within current_path do
        execute 'sudo service sidekiq start'
      end
    end
  end

  desc 'Copy service configuration for Sidekiq'
  task :setup do
    on roles(:app) do
      within current_path do
        service_config = File.read('config/ops/sidekiq.service').sub('ENV', fetch(:environment))
        File.write('tmp/sidekiq.service', service_config)

        upload! 'tmp/sidekiq.service', '/lib/systemd/system/sidekiq.service'
        execute 'sudo systemctl daemon-reload'
      end
    end
  end
end
