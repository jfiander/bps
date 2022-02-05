# frozen_string_literal: true

module Devise
  module Strategies
    class CognitoAuthenticable < Warden::Strategies::Base
      def valid?
        params.key?(:user) && username.present? && password.present?
      end

      def authenticate!
        auth = migrate.authenticate(username, password)
        certificate = cognito.certificate(auth)
        user = User.find_by(certificate: certificate)
        return success!(user) if user

        fail!('Authentication failed.')
      rescue Aws::CognitoIdentityProvider::Errors::NotAuthorizedException
        fail!('Authentication failed.')
      end

    private

      def cognito
        BPS::Cognito::Admin.new
      end

      def migrate
        BPS::Cognito::Migrate.new
      end

      def username
        params.fetch(:user)[:email]
      end

      def password
        params.fetch(:user)[:password]
      end
    end
  end
end
