# frozen_string_literal: true

# Admin API access for migrating users into Cognito user pools
module BPS
  module Cognito
    class Migrate
      include Shared

      # Attempt to authenticate with the given credentials.
      # Detect if the user already exists, or if we may need to create them in Cognito.
      def authenticate(username, password)
        admin.authenticate(username, password)
      rescue Aws::CognitoIdentityProvider::Errors::NotAuthorizedException => e
        raise e unless (user = local_authenticate(username, password))

        migrate_user(user, password: password)
        admin.authenticate(user.certificate, password)

        raise e
      end

      # Check if a username exists in Cognito.
      # Run legacy authentication.
      # If authenticated, create user in Cognito.
      # Otherwise, just give up unauthenticated.
      def migrate_user(user, password: nil)
        return if lookup_certificate(user.certificate)
      rescue Aws::CognitoIdentityProvider::Errors::UserNotFoundException
        import_user(user, password: password)
      end

      # Check if a certificate username exists in Cognito.
      def lookup_certificate(certificate)
        client.admin_get_user(
          user_pool_id: ENV['COGNITO_POOL_ID'],
          username: certificate
        )
      end

    private

      def admin
        @admin ||= BPS::Cognito::Admin.new
      end

      def import_user(user, password: nil)
        attributes = {
          name: user.simple_name,
          email: user.email,
          'custom:certificate' => user.certificate
        }
        attributes['custom:parent_certificate'] = user.parent.certificate if user.parent

        admin.create(user.certificate, attributes)
        admin.reset_password(user.certificate, password, permanent: true) if password
        user.certificate
      end

      def local_authenticate(username, password)
        user = ::User.where('email = ? OR certificate = ?', username, username).first
        return user if user&.valid_password?(password)
      end
    end
  end
end
