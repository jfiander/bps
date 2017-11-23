class Users::RegistrationsController < Devise::RegistrationsController
  #after_save { upload_profile_photo }
end
