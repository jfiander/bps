class Users::RegistrationsController < Devise::RegistrationsController
  def update
    super
    BpsS3.upload(update_params[:profile_photo], bucket: :files, key: "profile_photos/#{self.resource.certificate}.jpg")
  end

  def update_params
    params.require(:user).permit(:profile_photo, :first_name, :last_name, :email, :password, :password_confirmation)
  end
end
