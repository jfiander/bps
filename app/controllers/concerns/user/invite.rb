# frozen_string_literal: true

class User
  module Invite
    def invite
      user = User.find_by(id: clean_params[:id])
      redirect_to users_path, alert: 'User not found.' if user.blank?

      user.invite!
      redirect_to users_path, success: 'Invitation sent!'
    end

    def invite_all
      unless ENV['ALLOW_BULK_INVITE'] == 'true'
        redirect_to users_path, alert: 'This action is currently disabled.'
        return
      end

      User.invitable.each(&:invite!)
      redirect_to users_path, success: 'All new users have been sent invitations.'
    end
  end
end
