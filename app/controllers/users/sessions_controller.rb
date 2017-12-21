class Users::SessionsController < Devise::SessionsController
  def after_sign_in_path_for(resource)
      resource.sign_in_count == 1 ? welcome_path : members_path
  end
end
