class ApplicationController < ActionController::Base
  force_ssl if: :ssl_configured?
  protect_from_forgery with: :exception

  private
  def ssl_configured?
    Rails.env.production? || Rails.env.staging?
  end

  def require_permission(role)
    redirect_to root_path and return unless current_user&.permitted?(role)
    # before_action only: [:method_1, :method_2] { require_permission(:role_name) }
  end

  def current_user_is_admin?
    user_signed_in? && current_user.permitted?(:admin)
  end
end
