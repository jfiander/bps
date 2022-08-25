# frozen_string_literal: true

class User
  module Load
    # This module defines no public methods.
    def _; end

  private

    def find_user
      id = clean_params[:id] || current_user&.id
      @user = User.find_by(id: id)
      @role_icons = Role.icons
      return @user if @user.present?

      flash[:notice] = "Couldn't find that user." if current_user&.permitted?(:admin)
      redirect_to root_path
    end

    def load_users
      @show_locked = params[:locked].present?

      all_users = User.alphabetized.include_positions
      @user_roles = UserRole.preload
      @role_icons = Role.icons
      @bridge_offices = BridgeOffice.preload

      @unlocked = all_users.unlocked.map { |user| user_hash(user) }
      @locked = all_users.locked.map { |user| user_hash(user) }

      @users = @show_locked ? @locked : @unlocked
    end

    def user_hash(u)
      user_hash_personal(u).merge(user_hash_website(u))
    end

    def user_hash_personal(u)
      {
        id: u.id, name: u.full_name, certificate: u.certificate, mm: u.mm.to_i,
        email: u.email, senior: u.senior.present?, life: u.life.present?,
        bridge_office: bridge_office_for(u), granted_roles: u.granted_roles,
        permitted_roles: u.permitted_roles, implied_roles: u.implied_roles,
        rank_override: u.rank_override
      }
    end

    def user_hash_website(u)
      {
        invited_at: u.invitation_sent_at, current_login_at: u.current_sign_in_at,
        current_login_from: u.current_sign_in_ip,
        invitable: u.invitable?, invited: u.invited?, locked: u.locked?,
        new_layout: u.new_layout?, placeholder_email: u.placeholder_email?,
        in_latest_import: u.in_latest_import
      }
    end

    def bridge_office_for(user)
      @bridge_offices[user.id]
    end

    def user_has_explicit_roles?(user)
      @user_roles.key?(user.id)
    end

    def user_has_implicit_roles?(user)
      user.id.in?(users_with_implied)
    end

    def users_with_implied
      @users_with_implied ||= [
        BridgeOffice.all.map(&:user_id),
        StandingCommitteeOffice.current.map(&:user_id),
        Committee.all.map(&:user_id)
      ].flatten.uniq
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
