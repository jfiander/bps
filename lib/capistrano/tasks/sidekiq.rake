# frozen_string_literal: true

namespace :sidekiq do
  task :restart do
    on roles(:app) do
      within current_path do
        execute 'sudo service sidekiq restart'
      end
    end
  end

  before 'deploy:finished', 'sidekiq:restart'

  task :stop do
    on roles(:app) do
      within current_path do
        execute 'sudo service sidekiq stop'
      end
    end
  end

  task :start do
    on roles(:app) do
      within current_path do
        execute 'sudo service sidekiq start'
      end
    end
  end
end
