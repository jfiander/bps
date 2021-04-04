# frozen_string_literal: true

if defined? Rack::Cors
  Rails.configuration.middleware.insert_before 0, Rack::Cors do
    allow do
      origins [
        %r{\Ahttps?://(.*?)\.bpsd9.org(:\d+)?\z},
        %r{\Ahttps?://#{ENV['DOMAIN']}\z},
        %r{\Ahttps?://assets.#{ENV['DOMAIN']}\z}
      ]
      resource '/assets/*'
      resource '/webfonts/*'
    end
  end
end
