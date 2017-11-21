class Users::InvitationsController < Devise::InvitationsController
  def new
    @admin_menu = true
    super
  end
end
