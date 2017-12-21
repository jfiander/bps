class Users::InvitationsController < Devise::InvitationsController
  before_action :redirect_if_no_invitations

  def after_invite_path_for(resource)
    new_user_invitation_path
  end

  private
  def redirect_if_no_invitations
    redirect_to root_path, alert: "You do not have any invitations remaining." and return unless current_user&.invitation_limit > 0
  end
end
