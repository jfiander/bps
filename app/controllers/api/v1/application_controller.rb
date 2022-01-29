# frozen_string_literal: true

require 'ipaddr'

module Api
  module V1
    class ApplicationController < ActionController::API
      BAD_REQUEST = 'We could not process your request.'
      NOT_AUTHENTICATED = 'Authentication is required.'
      NOT_AUTHORIZED = 'You are not authorized to access that.'
      AUTHORIZATION_EXPIRED = 'Your authorization is expired. Please refresh.'

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

      def self.internal!(only: nil, except: nil)
        before_action(:validate_in_vpc!, only: only, except: except)
      end

    private

      def validate_user!
        key = request.headers['X-Key-ID']
        authenticate_with_http_token { |token, _options| user_from_credentials(key, token) }
      end

      def validate_in_vpc!
        deny_access! unless vpc?
      end

      def user_from_credentials(key, token)
        api_token = find_api_token(key)
        return not_authorized! unless api_token
        return authorization_expired! unless api_token.current?
        return not_authorized! unless api_token.match?(token)

        @current_user = api_token.user
      end

      def find_api_token(key)
        ApiToken.find_by(key: key)
      end

      def require_permission(*roles, strict: false)
        return if current_user&.permitted?(*roles, strict: strict)

        not_authorized!
      end

      def vpc?
        ENV['VPC_CIDRS'].split(' ').any? do |cidr|
          IPAddr.new(cidr).include?(request.remote_ip)
        end
      end

      def forbidden!
        deny_access!(NOT_AUTHENTICATED, :forbidden)
      end

      def not_authorized!
        deny_access!(NOT_AUTHORIZED, :unauthorized)
      end

      def authorization_expired!
        deny_access!(AUTHORIZATION_EXPIRED, :unauthorized)
      end

      def deny_access!(message = BAD_REQUEST, status = :bad_request)
        render(json: { error: message }, status: status)
      end
    end
  end
end
