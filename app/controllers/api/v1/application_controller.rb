# frozen_string_literal: true

require 'ipaddr'

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

      def self.internal!(only: nil, except: nil)
        before_action(:validate_in_vpc!, only: only, except: except)
      end

    private

      def validate_user!
        api_key = request.headers['X-Key-ID']
        authenticate_with_http_token do |token, _options|
          user_from_api_key(api_key).token_exists?(token) || invalid_token!(token)
        end || invalid_token!
      end

      def validate_in_vpc!
        not_authorized! unless vpc?
      end

      def user_from_api_key(api_key)
        @current_user = User.find_by(api_key: api_key)
      end

      def invalid_token!(token = nil)
        if @current_user.token_expired?(token)
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

      def vpc?
        ENV['VPC_CIDRS'].split(' ').any? do |cidr|
          IPAddr.new(cidr).include?(request.remote_ip)
        end
      end
    end
  end
end
