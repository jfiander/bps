# frozen_string_literal: true

module Api
  module V1
    class AuthController < ActionController::API
      ACCESS_RESTRICTIONS_NOT_ALLOWED = 'You are not allowed to set those access restrictions.'

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
        token = generate_token

        h = { api_key: token.key, token: token.new_token, expires_at: token.expires_at }
        h[:description] = clean_params[:description] if clean_params[:description].present?
        h
      end

      def generate_token
        if clean_params[:type] == 'JWT'
          validate_access_permissions!(clean_params[:access])
          create_jwt(access: clean_params[:access], certificate: user.certificate)
        else
          create_api_token
        end
      end

      def create_api_token
        user.create_token(
          persistent: clean_params[:persistent].present?,
          description: clean_params[:description]
        )
      end

      def validate_access_permissions!(access)
        access = format_access(access)
        raise Api::V1::JWT::AccessRestrictionError if access.blank?

        access.each do |a|
          controller = a.split(':')[2]
          controller == '*' ? verify_all_controllers : verify_controller(controller)
        end
      rescue Api::V1::JWT::AccessRestrictionError
        render(json: { error: ACCESS_RESTRICTIONS_NOT_ALLOWED }, status: :unauthorized)
      end

      def require_permission(*roles, strict: false)
        return if user&.permitted?(*roles, strict: strict)

        raise Api::V1::JWT::AccessRestrictionError
      end

      def verify_controller(controller)
        klass = "Api::V1::#{controller.classify}Controller".constantize
        require_permission(klass::REQUIRED_ROLES) if defined? klass::REQUIRED_ROLES
      end

      def verify_all_controllers
        controllers = Dir[Rails.root.join('app/controllers/api/v1/*_controller.rb')].map do |path|
          path.match(/(\w+)_controller.rb/)[1]
        end.compact - %w[auth application]

        controllers.each { |controller| verify_controller(controller) }
      end

      def unauthorized!
        render(json: { error: 'Invalid login.' }, status: :unauthorized)
      end
    end
  end
end
