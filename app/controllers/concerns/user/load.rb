# frozen_string_literal: true

class User
  module Load
    # This module defines no public methods.
    def _; end

  private

    def find_user
      id = clean_params[:id] || current_user&.id
      @user = User.find_by(id: id)
      return @user if @user.present?

      if current_user&.permitted?(:admin, session: session)
        flash[:notice] = "Couldn't find that user."
      end
      redirect_to root_path
    end

    def load_users
      @users = User.alphabetized
                   .includes(:bridge_office, :committees, :standing_committee_offices, user_roles: :role)
                   .order('locked_at IS NULL')

      @unlocked = @users.where(locked_at: nil).count
      @locked = @users.where.not(locked_at: nil).count
      @role_icons = Role.icons
      @bridge_offices = BridgeOffice.preload
    end

    def users_for_select
      @users = User.unlocked.alphabetized.include_positions.map do |user|
        [
          (user.full_name.present? ? user.full_name(html: false) : user.email),
          user.id
        ]
      end
    end
  end
end
