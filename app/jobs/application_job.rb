# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  include Rails.application.routes.url_helpers

  queue_as :default

private

  def default_url_options
    Rails.application.config.active_job.default_url_options
  end
end
