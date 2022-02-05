# frozen_string_literal: true

require 'net/http'
require 'net/https'

module BPS
  module Cognito
    class TokenRequest
      REQUEST_URL = 'https://auth.bpsd9.org/oauth2/token'
      FORM_CONTENT_TYPE = 'application/x-www-form-urlencoded; charset=utf-8'

      def call(auth_code)
        uri = URI(REQUEST_URL)

        req = Net::HTTP::Post.new(uri)
        req.add_field('Content-Type', FORM_CONTENT_TYPE)
        req.add_field('Authorization', "Basic #{client_secret_code}")
        req.set_form_data(request_data(auth_code))

        submit(uri, req)
      end

    private

      def client(uri)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http
      end

      def client_secret_code
        secret = [
          ENV['COGNITO_APP_CLIENT_ID'],
          ENV['COGNITO_SECRET']
        ].join(':')
        Base64.encode64(secret).squish
      end

      def request_data(auth_code)
        {
          grant_type: 'authorization_code',
          code: auth_code,
          redirect_uri: "http#{'s' unless Rails.env.development?}://#{ENV['DOMAIN']}/auth"
        }
      end

      def submit(uri, req)
        result = client(uri).request(req)
        return result if result.code == '200'

        raise TokenRequestError.new(
          'Response error received',
          code: result.code, body: JSON.parse(result.response.body), uri: uri, request: req
        )
      end

      class TokenRequestError < StandardError
        attr_reader :metadata

        def initialize(message, **metadata)
          super(message)
          @metadata = metadata
        end

        def bugsnag_meta_data
          {
            code: metadata[:code],
            request: metadata[:request],
            response: metadata[:response]
          }
        end
      end
    end
  end
end
