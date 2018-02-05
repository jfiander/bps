if defined? Rack::Cors
    Rails.configuration.middleware.insert_before 0, Rack::Cors do
        allow do
            origins [
              "https://#{ENV['DOMAIN']}",
              "http://#{ENV['DOMAIN']}",
              "https://#{ENV['CLOUDFRONT_RAILS_ENDPOINT']}",
              "http://#{ENV['CLOUDFRONT_RAILS_ENDPOINT']}"
            ]
            resource '/assets/*'
        end
    end
end
