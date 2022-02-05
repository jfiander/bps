# frozen_string_literal: true

# Messaging template updating for Cognito
module BPS
  module Cognito
    class Config
      include Shared

      # Updates the pool config, including re-rendering email templates
      #
      # Without sending all of these values, they will be cleared on update
      def update
        client.update_user_pool(
          user_pool_id: ENV['COGNITO_POOL_ID'],
          policies: policies,
          auto_verified_attributes: %w[email],
          verification_message_template: verification_message_template,
          mfa_configuration: 'OPTIONAL',
          device_configuration: device_configuration,
          email_configuration: email_configuration,
          admin_create_user_config: admin_create_user_config,
          user_pool_add_ons: { advanced_security_mode: 'OFF' },
          account_recovery_setting: account_recovery_setting
        )
      end

      def describe
        client.describe_user_pool(user_pool_id: ENV['COGNITO_POOL_ID'])
      end

    private

      def email_layout
        @email_layout ||= ApplicationController.renderer.render(partial: 'cognito/layout')
      end

      def render_email(template)
        partial = ApplicationController.renderer.render(partial: "cognito/#{template}")
        email_layout.dup.sub('##YIELD##', partial)
      end

      def policies
        {
          password_policy: {
            minimum_length: ENV['COGNITO_PASSWORD_LENGTH'],
            require_uppercase: true,
            require_lowercase: true,
            require_numbers: true,
            require_symbols: true,
            temporary_password_validity_days: ENV['COGNITO_PASSWORD_EXPIRATION']
          }
        }
      end

      def verification_message_template
        {
          email_subject_by_link: 'Please verify your email',
          email_message_by_link: render_email(:verify),
          default_email_option: 'CONFIRM_WITH_LINK'
        }
      end

      def device_configuration
        {
          challenge_required_on_new_device: false,
          device_only_remembered_on_user_prompt: false
        }
      end

      def email_configuration
        {
          source_arn: ENV['COGNITO_EMAIL_SOURCE_ARN'],
          email_sending_account: 'DEVELOPER',
          from: '"BPS Support" <support@bpsd9.org>'
        }
      end

      def admin_create_user_config
        {
          allow_admin_create_user_only: true,
          invite_message_template: {
            email_subject: "Welcome to America's Boating Club - Birmingham Squadron!",
            email_message: render_email(:invite)
          }
        }
      end

      def account_recovery_setting
        {
          recovery_mechanisms: [
            {
              priority: 1,
              name: 'verified_email'
            }
          ]
        }
      end
    end
  end
end
