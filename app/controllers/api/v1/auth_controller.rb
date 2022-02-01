# frozen_string_literal: true

module Api
  module V1
    class AuthController < ActionController::API
      include Api::V1::JWT::Encode

      def login
        with_valid_user { render(json: token_hash) }
      end

    private

      def clean_params
        params.permit(:email, :password, :type, :persistent, :description, :access)
      end

      def user
        @user ||= User.find_by(email: clean_params[:email])
      end

      def with_valid_user
        user&.valid_password?(clean_params[:password]) ? yield : unauthorized!
      end

      def token_hash
        token =
          if clean_params[:type] == 'JWT'
            create_jwt(access: clean_params[:access])
          else
            create_api_token
          end

        h = { api_key: token.key, token: token.new_token, expires_at: token.expires_at }
        h[:description] = clean_params[:description] if clean_params[:description].present?
        h
      end

      def create_api_token
        user.create_token(
          persistent: clean_params[:persistent].present?,
          description: clean_params[:description]
        )
      end

      def unauthorized!
        render(json: { error: 'Invalid login.' }, status: :unauthorized)
      end
    end
  end
end
