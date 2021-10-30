# frozen_string_literal: true

module Api
  module V1
    class ApplicationController < ActionController::API
      AUTHORIZATION_EXPIRED = 'Authorization expired. Please refresh.'
      NOT_AUTHORIZED = 'You are not authorized to access that.'

      include ActionController::HttpAuthentication::Token::ControllerMethods

      def self.authenticate_user!
        before_action :validate_user!
      end

    private

      def validate_user!
        authenticate_with_http_token do |token, _options|
          user_from_token(token).present? ? true : invalid_token!(token)
        end || invalid_token!
      end

      def user_from_token(token)
        @user = ApiToken.current.find_by(token: token)&.user if token.present?
      end

      def invalid_token!(token = nil)
        if ApiToken.expired.find_by(token: token)
          render(json: { error: AUTHORIZATION_EXPIRED }, status: :unauthorized)
        else
          render(json: { error: NOT_AUTHORIZED }, status: :forbidden)
        end
      end
    end
  end
end
