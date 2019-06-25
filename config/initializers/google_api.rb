# frozen_string_literal: true

GoogleAPI.configure do |config|
  config.root = Rails.root.join('tmp', 'google_api')
  config.keys = Rails.root.join('config', 'keys')
end
