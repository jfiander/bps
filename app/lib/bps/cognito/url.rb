# frozen_string_literal: true

# User token access for managing Cognito user authentication
module BPS
  module Cognito
    class URL
      LINKS = %w[login logout forgot].freeze

      AUTH_BASE = 'https://auth.bpsd9.org'

      LINKS.each do |link|
        define_singleton_method(link) { new.public_send(link) }
      end

      def login
        url('login')
      end

      def logout
        url('logout')
      end

      def forgot
        url('forgotPassword')
      end

    private

      def protocol
        "http#{'s' if Rails.env.deployed?}"
      end

      def base
        "#{protocol}://#{ENV['DOMAIN']}"
      end

      def url(path)
        "#{AUTH_BASE}/#{path}?response_type=code" \
          "&client_id=#{ENV['COGNITO_APP_CLIENT_ID']}" \
          "&redirect_uri=#{base}/auth"
      end
    end
  end
end
