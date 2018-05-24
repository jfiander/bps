# frozen_string_literal: true

class Users::InvitationsController < Devise::InvitationsController
  before_action :redirect_if_no_invitations, except: %i[edit update]
  before_action :block_inviting_invalid_users, only: :create

  def after_invite_path_for(resource)
    new_user_invitation_path
  end

  private

  def redirect_if_no_invitations
    return if current_user&.permitted?(:users)

    redirect_to(
      root_path, alert: 'You do not have any invitations remaining.'
    )
  end

  def block_inviting_invalid_users
    user = User.find_by(email: invite_params[:email])
    return if user.blank?

    if user.invitable?
      flash[:notice] = 'You can also invite imported users from the users list.'
      return
    end

    flash[:alert] = 'You cannot invite a user who has already logged in.'
    redirect_to(new_user_invitation_path)
  end

  def invite_resource
    if (user = User.find_by(email: invite_params[:email]))
      user.invite!
      flash[:success] = "Invitation sent to #{user.email}!"
      flash[:notice] = 'You can also invite imported users from the users list.'
      user
    else
      flash[:success] = "Invitation sent to #{invite_params[:email]}!"
      super
    end
  end
end
