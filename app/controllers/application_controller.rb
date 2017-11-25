class ApplicationController < ActionController::Base
  force_ssl if: :ssl_configured?
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  private
  def ssl_configured?
    Rails.env.production? || Rails.env.staging?
  end

  def require_permission(role)
    redirect_to root_path and return unless current_user&.permitted?(role)
    # before_action only: [:method_1, :method_2] { require_permission(:role_name) }
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [:profile_photo, :rank, :first_name, :last_name])
  end
end
