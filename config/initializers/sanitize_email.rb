# frozen_string_literal: true

SanitizeEmail::Config.configure do |config|
  config[:sanitized_to] = 'dev@bpsd9.org'
  config[:activation_proc] = proc { !Rails.env.production? }
  config[:use_actual_email_prepended_to_subject] = true
  config[:use_actual_environment_prepended_to_subject] = true
  config[:use_actual_email_as_sanitized_user_name] = true
end
