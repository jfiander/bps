# frozen_string_literal: true

module Api
  module V1
    class UserVerifyController < ActionController::API
      include ActionController::HttpAuthentication::Token::ControllerMethods

      before_action :validate_user!

      def verify
        return head(:no_content) if request_string.blank?

        matched_users = users_from_string(request_string)

        if matched_users.any?
          data = matched_users.compact.map do |user|
            { certificate: user.certificate, name: user.simple_name }
          end
          render(json: { users: data }, status: :ok)
        else
          render(json: { error: 'No users found' }, status: :not_found)
        end
      end

    private

      # Originally copied from Events::Update
      def users_from_string(users_string)
        users_string.split("\n").each_with_object([]) do |user_string, users|
          users << find_user(user_string)
        end
      end

      def find_user(user_string)
        if user_string.match?(%r{/})
          User.find_by(certificate: user_string.split('/').last.squish.upcase)
        else
          User.with_name(user_string).first
        end
      end

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
          render(json: { error: 'Authorization expired. Please refresh.' }, status: :unauthorized)
        else
          render(json: { error: 'You are not authorized to access that.' }, status: :forbidden)
        end
      end

      def request_string
        @request_string ||= ActionController::Base.helpers.sanitize(request.body.read)
      end
    end
  end
end
