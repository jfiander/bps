# frozen_string_literal: true

# The systemd unit (`sidekiq@.service`) is installed by the AMI's
# install.sh; this task just bounces the per-stage instance.

namespace :sidekiq do
  def sidekiq_unit
    "sidekiq@#{fetch(:environment)}"
  end

  desc 'Restart Sidekiq'
  task :restart do
    on roles(:app) do
      execute :sudo, :systemctl, :restart, sidekiq_unit
    end
  end

  desc 'Stop Sidekiq'
  task :stop do
    on roles(:app) do
      execute :sudo, :systemctl, :stop, sidekiq_unit
    end
  end

  desc 'Start Sidekiq'
  task :start do
    on roles(:app) do
      execute :sudo, :systemctl, :start, sidekiq_unit
    end
  end

  before 'deploy:finished', 'sidekiq:restart'
end
