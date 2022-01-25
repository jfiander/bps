# frozen_string_literal: true

module Api
  module V1
    class ApplicationController < ActionController::API
      AUTHORIZATION_EXPIRED = 'Authorization expired. Please refresh.'
      NOT_AUTHORIZED = 'You are not authorized to access that.'

      include ActionController::HttpAuthentication::Token::ControllerMethods

      attr_reader :current_user

      def self.authenticate_user!
        before_action :validate_user!
      end

      def self.secure!(*roles, strict: false, only: nil, except: nil)
        before_action(:validate_user!, only: only, except: except)
        return if roles.blank?

        before_action(only: only, except: except) { require_permission(*roles, strict: strict) }
      end

    private

      def validate_user!
        authenticate_with_http_token do |token, _options|
          user_from_token(token).present? ? true : invalid_token!(token)
        end || invalid_token!
      end

      def user_from_token(token)
        @current_user = ApiToken.current.find_by(token: token)&.user if token.present?
      end

      def invalid_token!(token = nil)
        if ApiToken.expired.find_by(token: token)
          render(json: { error: AUTHORIZATION_EXPIRED }, status: :unauthorized)
        else
          not_authorized!
        end
      end

      def require_permission(*roles, strict: false)
        return if current_user&.permitted?(*roles, strict: strict)

        not_authorized!
      end

      def not_authorized!
        render(json: { error: NOT_AUTHORIZED }, status: :forbidden)
      end
    end
  end
end
