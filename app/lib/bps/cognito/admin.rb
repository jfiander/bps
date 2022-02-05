# frozen_string_literal: true

# Admin API access for managing Cognito user pools and user authentication
module BPS
  module Cognito
    class Admin
      include Shared

      # To authenticate with email, it must first be verified
      def authenticate(username_or_email, password)
        client.admin_initiate_auth(
          user_pool_id: ENV['COGNITO_POOL_ID'],
          client_id: ENV['COGNITO_APP_CLIENT_ID'],
          auth_flow: 'ADMIN_NO_SRP_AUTH',
          auth_parameters: auth_parameters(username_or_email, password)
        )
      end

      def refresh(username, refresh_token)
        client.admin_initiate_auth(
          user_pool_id: ENV['COGNITO_POOL_ID'],
          client_id: ENV['COGNITO_APP_CLIENT_ID'],
          auth_flow: 'REFRESH_TOKEN_AUTH',
          auth_parameters: refresh_auth_parameters(username, refresh_token)
        )
      end

      def logout(username)
        client.admin_user_global_sign_out(username: username)
      end

      def create(username, attributes = {})
        client.admin_create_user(
          user_pool_id: ENV['COGNITO_POOL_ID'],
          username: username,
          user_attributes: attributes.map { |k, v| { name: k, value: v } },
          message_action: 'SUPPRESS', # RESEND - available if user already exists
          desired_delivery_mediums: ['EMAIL'] # EMAIL, SMS
        )
      end

      def reset_password(username, password, permanent: false)
        client.admin_set_user_password(
          user_pool_id: ENV['COGNITO_POOL_ID'],
          username: username,
          password: password,
          permanent: permanent
        )
      end

      def update(username, attributes = {})
        client.admin_update_user_attributes(
          user_pool_id: ENV['COGNITO_POOL_ID'],
          username: username,
          user_attributes: attributes.map { |k, v| { name: k, value: v } }
        )
      end

      def get_user(username)
        client.admin_get_user(
          user_pool_id: ENV['COGNITO_POOL_ID'],
          username: username
        )
      end

      def get_user_by_email(email)
        client.list_users(
          user_pool_id: ENV['COGNITO_POOL_ID'],
          attributes_to_get: %w[email],
          limit: 1,
          filter: "email = \"#{email}\""
        ).users[0]
      end

      def enable(username)
        client.admin_enable_user(
          user_pool_id: ENV['COGNITO_POOL_ID'],
          username: username
        )
      end

      def disable(username)
        client.admin_disable_user(
          user_pool_id: ENV['COGNITO_POOL_ID'],
          username: username
        )
      end

      def set_mfa(username, state)
        client.admin_set_user_mfa_preference(
          user_pool_id: ENV['COGNITO_POOL_ID'],
          username: username,
          software_token_mfa_settings: {
            enabled: state,
            preferred_mfa: state
          }
        )
      end

      def describe
        client.describe_user_pool(user_pool_id: ENV['COGNITO_POOL_ID']).user_pool
      end

      def password_policy
        describe.policies.password_policy
      end

    private

      def auth_parameters(username, password)
        {
          USERNAME: username,
          PASSWORD: password,
          SECRET_HASH: secret_hash(username)
        }
      end

      def refresh_auth_parameters(username, refresh_token)
        {
          REFRESH_TOKEN: refresh_token,
          SECRET_HASH: secret_hash(username)
        }
      end
    end
  end
end
