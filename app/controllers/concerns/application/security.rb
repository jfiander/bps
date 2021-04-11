# frozen_string_literal: true

module Application
  module Security
    module ClassMethods
      def secure!(*roles, strict: false, only: nil, except: nil)
        before_action(only: only, except: except) { authenticate_user! }
        return if roles.blank?

        before_action(only: only, except: except) { require_permission(*roles, strict: strict) }
      end
    end

    def self.included(klass)
      klass.extend(ClassMethods)
    end

  private

    def ssl_configured?
      Rails.env.deployed? && request.host !~ /.#{ENV['INTERNAL_DOMAIN']}$/
    end

    def handle_unverified_request
      flash[:alert] = 'Sorry, please try that again.'
      redirect_to :back
    rescue StandardError
      redirect_to root_path
    end

    def require_permission(*roles, strict: false)
      return if current_user&.permitted?(*roles, strict: strict)

      redirect_to root_path
    end

    def authenticate_user!(*args)
      return super(*args) if user_signed_in?

      flash[:referrer] = request.original_fullpath
      flash[:notice] = 'You must login to continue.'
      redirect_to new_user_session_path
    end

    def authenticate_inviter!
      unless current_user&.permitted?(:users)
        redirect_to(root_path)
        return
      end

      super
    end

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(
        :account_update,
        keys: %i[
          profile_photo rank first_name last_name jumpstart subscribe_on_register
          phone_h phone_c phone_w
        ]
      )
    end

    def cache_user_permissions
      return unless current_user.present?

      session[:granted] = current_user.granted_roles
      session[:permitted] = current_user.permitted_roles
    end
  end
end
