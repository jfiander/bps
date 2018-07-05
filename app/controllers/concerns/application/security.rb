# frozen_string_literal: true

module Application::Security
  module ClassMethods
    def secure!(*roles, strict: false, only: nil, except: nil)
      before_action(:authenticate_user!, only: only, except: except)

      return unless only.present? || except.present?
      before_action(only: only, except: except) do
        require_permission(*roles, strict: strict)
      end
    end
  end

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  private

  def ssl_configured?
    Rails.env.production?
  end

  def handle_unverified_request
    flash[:alert] = 'Sorry, please try that again.'
    redirect_to :back
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
      redirect_to root_path
      return
    end

    super
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(
      :account_update,
      keys: %i[profile_photo rank first_name last_name]
    )
  end
end
