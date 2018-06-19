# frozen_string_literal: true

module User::Load
  private

  def find_user
    id = clean_params[:id] || current_user&.id
    @user = User.find_by(id: id)
    return @user if @user.present?

    if current_user&.permitted?(:admin)
      flash[:notice] = "Couldn't find that user."
    end
    redirect_to root_path
  end

  def load_users
    all_users = User.alphabetized.with_positions
    @user_roles = UserRole.preload
    @bridge_offices = BridgeOffice.preload

    @unlocked = all_users.unlocked.map { |user| user_hash(user) }
    @locked = all_users.locked.map { |user| user_hash(user) }
    @users = @unlocked + @locked
  end

  def user_hash(user)
    {
      id:                 user.id,
      name:               user.full_name(html: false),
      certificate:        user.certificate,
      email:              user.email,
      granted_roles:      granted_roles_for(user),
      permitted_roles:    permitted_roles_for(user),
      bridge_office:      bridge_office_for(user),
      current_login_at:   user.current_sign_in_at,
      current_login_from: user.current_sign_in_ip,
      invited_at:         user.invitation_sent_at,
      invitable:          user.invitable?,
      placeholder_email:  user.placeholder_email?,
      invited:            user.invited?,
      locked:             user.locked?,
      senior:             user.senior.present?,
      life:               user.life.present?
    }
  end

  def granted_roles_for(user)
    user_has_explicit_roles?(user) ? @user_roles[user.id] : []
  end

  def permitted_roles_for(user)
    user_has_implicit_roles?(user) ? user.permitted_roles : []
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
    @users_with_implied ||= BridgeOffice.all.map(&:user_id) +
                            StandingCommitteeOffice.current.map(&:user_id) +
                            Committee.all.map(&:user_id)
  end

  def users_for_select
    @users = User.unlocked.alphabetized.with_positions.map do |user|
      [(user.full_name(html: false) || user.email), user.id]
    end
  end
end
