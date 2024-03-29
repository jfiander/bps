# frozen_string_literal: true

require 'ipaddr'

module Api
  module V1
    class ApplicationController < ::ActionController::API
      BAD_REQUEST = 'We could not process your request.'
      NOT_AUTHENTICATED = 'Authentication is required.'
      NOT_AUTHORIZED = 'You are not authorized to access that.'
      AUTHORIZATION_EXPIRED = 'Your authorization is expired. Please refresh.'

      include Api::V1::JWT::Decode

      attr_reader :current_user

      def self.authenticate_user!
        before_action :validate_user!
      end

      def self.internal!(only: nil, except: nil)
        before_action(:validate_in_vpc!, only: only, except: except)
      end

    private

      def validate_user!
        auth_header = request.headers['Authorization']
        if auth_header.nil?
          not_authorized!
        elsif auth_header =~ /^JWT /
          user_from_jwt(auth_header) || not_authorized!
        else
          user_from_bearer(auth_header) || not_authorized!
        end
      end

      def user_from_jwt(auth_header)
        token = auth_header.split.last
        jwt = decode_jwt(token)
        @current_user = User.find_by(certificate: jwt[0]['data']['certificate'])
      end

      def user_from_bearer(auth_header)
        key = request.headers['X-Key-ID']
        token = auth_header.split.last
        user_from_credentials(key, token)
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
        at = ApiToken.find_by(key: key)
        at.expires_at.nil? ? at.becomes(PersistentApiToken) : at
      end

      def vpc?
        ENV['VPC_CIDRS'].split.any? do |cidr|
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
