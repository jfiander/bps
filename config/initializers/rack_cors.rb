# frozen_string_literal: true

if defined? Rack::Cors
  Rails.configuration.middleware.insert_before 0, Rack::Cors do
    allow do
      domain = ENV['DOMAIN']
      assets = ENV['CLOUDFRONT_RAILS_ENDPOINT']
      origins [
        %r{\Ahttps?://(.*?)\.bpsd9.org(:\d+)?\z},
        %r{\Ahttps?://#{domain}\z},
        %r{\Ahttps?://#{assets}\z}
      ]
      resource '/assets/*'
      resource '/webfonts/*'
    end
  end
end
