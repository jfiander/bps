module UserMethods
  def find_user
    @user = User.find_by(id: clean_params[:id])
    unless @user.present?
      if current_user&.permitted?(:admin)
        flash[:notice] = "Couldn't find that user."
      end
      redirect_to root_path
    end
  end

  def get_users
    all_users ||= User.alphabetized.with_positions
    @user_roles ||= UserRole.preload
    @bridge_offices ||= BridgeOffice.preload

    @users = all_users.unlocked.map { |user| user_hash(user) } + all_users.locked.map { |user| user_hash(user) }
  end

  def user_hash(user)
    {
      id:                 user.id,
      name:               user.full_name(html: false),
      certificate:        user.certificate,
      email:              user.email,
      granted_roles:      get_granted_roles_for(user),
      permitted_roles:    get_permitted_roles_for(user),
      bridge_office:      get_bridge_office_for(user),
      current_login_at:   user.current_sign_in_at,
      current_login_from: user.current_sign_in_ip,
      invited_at:         user.invitation_sent_at,
      invitable:          user.invitable?,
      placeholder_email:  user.has_placeholder_email?,
      invited:            user.invited?,
      locked:             user.locked?
    }
  end

  def get_granted_roles_for(user)
    user_has_explicit_roles?(user) ? @user_roles[user.id] : []
  end

  def get_permitted_roles_for(user)
    user_has_implicit_roles?(user) ? user.permitted_roles : []
  end

  def get_bridge_office_for(user)
    @bridge_offices[user.id]
  end

  def user_has_explicit_roles?(user)
    @user_roles.has_key? user.id
  end

  def user_has_implicit_roles?(user)
    user.id.in? (@users_with_implied_permissions ||= users_with_implied_permissions)
  end

  def users_with_implied_permissions
    BridgeOffice.all.map(&:user_id) +
    StandingCommitteeOffice.current.map(&:user_id) +
    Committee.all.map(&:user_id)
  end

  def get_users_for_select
    @users = User.unlocked.alphabetized.with_positions.map do |user|
      user.full_name.present? ? [user.full_name(html: false), user.id] : [user.email, user.id]
    end
  end

  def clean_params
    params.permit(:id, :user_id, :role, :permit_id, :committee, :department, :bridge_office, :type, :page_name,
      :committee_name, :chair, :term_length, :import_file, :photo, :redirect_to, term_start_at: ["(1i)", "(2i)", "(3i)"])
  end
end
