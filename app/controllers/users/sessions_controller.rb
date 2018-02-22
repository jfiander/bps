class Users::SessionsController < Devise::SessionsController
  def after_sign_in_path_for(resource)
    return welcome_path if resource.sign_in_count == 1
    return referrer_params[:user][:referrer] if useful_referrer?
    members_path
  end

  private

  def useful_referrer?
    referrer_params[:user][:referrer].present? &&
      referrer_params[:user][:referrer] != '/login'
  end

  def referrer_params
    params.permit(user: :referrer)
  end
end
