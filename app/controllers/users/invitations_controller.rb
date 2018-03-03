class Users::InvitationsController < Devise::InvitationsController
  before_action :redirect_if_no_invitations, except: %i[edit update]

  def after_invite_path_for(resource)
    new_user_invitation_path
  end

  private
  def redirect_if_no_invitations
    unless current_user&.permitted?(:users)
      redirect_to(
        root_path,
        alert: 'You do not have any invitations remaining.'
      )
    end
  end
end
