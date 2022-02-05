# frozen_string_literal: true

# User token access for managing Cognito user authentication
module BPS
  module Cognito
    class User
      include Shared

      def get(access_token)
        client.get_user(access_token: access_token)
      end

      # Request verification of email or phone
      def check(access_token, attribute)
        client.get_user_attribute_verification_code(
          access_token: access_token,
          attribute_name: attribute
        )
      end

      # Verify email or phone
      def verify(access_token, attribute, code)
        client.verify_user_attribute(
          access_token: access_token,
          attribute_name: attribute,
          code: code
        )
      end

      def associate_mfa(access_token)
        mfa = client.associate_software_token(access_token: access_token)
        certificate = decode(access_token)[0]['username']
        secret = mfa.secret_code
        otp = "otpauth://totp/bpsd9:#{certificate}?secret=#{secret}&issuer=bpsd9"

        {
          svg: mfa_qr_svg(otp),
          text: secret
        }
      end

      def verify_mfa(access_token, user_code, description: nil)
        client.verify_software_token(
          access_token: access_token,
          user_code: user_code,
          friendly_device_name: description
        )
      end

      # If you want MFA to be applied selectively based on the assessed risk level of
      # sign-in attempts, deactivate MFA for users and turn on
      # Adaptive Authentication for the user pool.
      def set_mfa(access_token, state)
        client.set_user_mfa_preference(
          sms_mfa_settings: {
            enabled: false,
            preferred_mfa: false
          },
          software_token_mfa_settings: {
            enabled: state,
            preferred_mfa: state
          },
          access_token: access_token
        )
      end

      def logout(access_token)
        client.global_sign_out(access_token: access_token)
      end

      def revoke(refresh_token)
        client.revoke_token(
          token: refresh_token,
          client_id: ENV['COGNITO_APP_CLIENT_ID'],
          client_secret: ENV['COGNITO_SECRET']
        )
      end

      def change_password(access_token, current_password, new_password)
        client.change_password(
          previous_password: current_password,
          proposed_password: new_password,
          access_token: access_token
        )
      end

      def forgot_password(username)
        client.forgot_password(
          client_id: ENV['COGNITO_APP_CLIENT_ID'],
          secret_hash: secret_hash(username),
          username: username
        )
      end

      def confirm_forgot_password(username, user_code, new_password)
        client.confirm_forgot_password(
          client_id: ENV['COGNITO_APP_CLIENT_ID'],
          secret_hash: secret_hash(username),
          username: username,
          confirmation_code: user_code,
          password: new_password
        )
      end

      def login_url
        callback_url = "http#{'s' unless Rails.env.development?}://#{ENV['DOMAIN']}/auth"

        'https://auth.bpsd9.org/login?response_type=code' \
          "&client_id=#{ENV['COGNITO_APP_CLIENT_ID']}" \
          "&redirect_uri=#{callback_url}"
      end

    private

      def mfa_qr_svg(secret, scale: 11, border: 11)
        RQRCode::QRCode.new(secret).as_svg(
          color: '041E42',
          fill: 'FFFFFF',
          offset: border,
          module_px_size: scale,
          use_path: true,
          viewbox: true
        )
      end
    end
  end
end
