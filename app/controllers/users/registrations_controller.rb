class Users::RegistrationsController < Devise::RegistrationsController
  def after_update_path_for(resource)
    current_user_path
  end

  def update_params
    params.require(:user).permit(:profile_photo, :first_name, :last_name, :email, :password, :password_confirmation)
  end
end
