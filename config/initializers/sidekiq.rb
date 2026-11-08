# frozen_string_literal: true

# Recurring jobs, listed in config/sidekiq_scheduler.yml, run in production only. Staging reads the same global buckets
# (such as bps-dmarc-reports), so it must not run them too.
Sidekiq.configure_server do |config|
  config.on(:startup) do
    next unless Rails.env.production?

    Sidekiq.schedule = YAML.safe_load_file(Rails.root.join('config/sidekiq_scheduler.yml'))
    SidekiqScheduler::Scheduler.instance.reload_schedule!
  end
end
