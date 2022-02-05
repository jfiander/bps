# frozen_string_literal: true

# Shared context for Cognito access
module BPS
  module Cognito
    module Shared
      def decode(token)
        jwk_loader = lambda do |options|
          @cached_keys = nil if options[:invalidate]
          @cached_keys ||= { keys: jwks }
        end

        JWT.decode(token, nil, true, { algorithm: 'RS256', jwks: jwk_loader })
      end

      def certificate(auth)
        decode(auth.authentication_result.id_token)[0]['custom:certificate']
      end

    private

      def client
        Aws::CognitoIdentityProvider::Client.new(cognito_attributes)
      end

      def cognito_attributes
        attributes = { region: 'us-east-2' }

        unless Rails.env.deployed?
          attributes.merge!(
            credentials: Aws::Credentials.new(
              ENV['AWS_ACCESS_KEY'],
              ENV['AWS_SECRET']
            )
          )
        end

        attributes
      end

      def secret_hash(username)
        data = [username, ENV['COGNITO_APP_CLIENT_ID']].join
        digest = OpenSSL::HMAC.digest('SHA256', ENV['COGNITO_SECRET'], data)
        Base64.encode64(digest).rstrip
      end

      def jwks
        return @jwks if @jwks

        IO.copy_stream(URI.open(jwt_keys_url), jwks_path) unless File.exist?(jwks_path)

        @jwks = JSON.parse(File.read(jwks_path))['keys']
      end

      def jwt_keys_url
        'https://cognito-idp.us-east-2.amazonaws.com/' \
          "#{ENV['COGNITO_POOL_ID']}/.well-known/jwks.json"
      end

      def jwks_path
        Rails.root.join("config/keys/jwks-#{ENV['COGNITO_APP_CLIENT_ID']}.json")
      end

      def jwk_loader(options)
        @cached_keys = nil if options[:invalidate]
        @cached_keys ||= { keys: jwks }
      end
    end
  end
end
