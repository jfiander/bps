Recaptcha.configure do |config|
  config.site_key = ENV.fetch('RECAPTCHA_SITE_KEY', '')
  config.secret_key = ENV.fetch('RECAPTCHA_SECRET_KEY', '')

  # Google rejects localhost for the site key, so development skips verification
  # (and ApplicationHelper#recaptcha_tags skips the widget).
  config.skip_verify_env << 'development'
end
