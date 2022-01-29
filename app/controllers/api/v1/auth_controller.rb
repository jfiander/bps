# frozen_string_literal: true

module Api
  module V1
    class AuthController < ActionController::API
      def login
        with_valid_user { render(json: token_hash) }
      end

    private

      def clean_params
        params.permit(:email, :password, :persistent, :description)
      end

      def user
        @user ||= User.find_by(email: clean_params[:email])
      end

      def with_valid_user
        user&.valid_password?(clean_params[:password]) ? yield : unauthorized!
      end

      def token_hash
        token = user.create_token(
          persistent: clean_params[:persistent].present?,
          description: clean_params[:description]
        )

        h = { api_key: token.key, token: token.new_token, expires_at: token.expires_at }
        h[:description] = clean_params[:description] if clean_params[:description].present?
        h
      end

      def unauthorized!
        render(json: { error: 'Invalid login.' }, status: :unauthorized)
      end
    end
  end
end
