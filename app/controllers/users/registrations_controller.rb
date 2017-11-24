class Users::RegistrationsController < Devise::RegistrationsController
  def update
    BpsS3.upload(update_params[:profile_photo], bucket: :files, key: "profile_photos/#{self.resource.certificate}.jpg") if update_params[:profile_photo].present?
    super
  end

  def update_params
    params.require(:user).permit(:profile_photo, :first_name, :last_name, :email, :password, :password_confirmation)
  end
end
