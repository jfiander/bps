class UserController < ApplicationController
  before_action :authenticate_user!
  before_action                      except: [:current, :show, :register, :cancel_registration] { require_permission(:users) }

  before_action :get_users,            only: [:list]
  before_action :get_users_for_select, only: [:permissions_index, :assign_bridge, :assign_committee]
  before_action :time_formats,         only: [:show]

  def current
    redirect_to user_path(id: current_user.id)
  end

  def show
    redirect_to user_path(current_user.id) and return unless clean_params[:id].to_i == current_user.id || current_user.permitted?(:admin)

    @user = User.find(clean_params[:id])

    @registrations = Registration.for_user(@user.id).current

    @profile_title = @user.id == current_user.id ? "Current" : "Selected"

    respond_to do |format|
        format.html
        format.json { render :json => @user }
    end
  end

  def list
    respond_to do |format|
      format.html
      format.json { render :json => @users }
    end
  end

  def permissions_index
    @roles = Role.all.map(&:name)
    @roles.delete("admin")

    respond_to do |format|
      format.html
    end
  end

  def permissions_add
    redirect_to permit_path, alert: "User was not selected." and return if clean_params[:user_id].blank?
    redirect_to permit_path, alert: "Role was not selected." and return if clean_params[:role].blank?
    redirect_to permit_path, alert: "Cannot add admin permissions." and return if clean_params[:role] == "admin"

    user = User.find_by(id: clean_params[:user_id])
    role = Role.find_by(name: clean_params[:role])

    redirect_to permit_path, alert: "Selected user already has that permission." and return if UserRole.find_by(user: user, role: role)

    UserRole.create!(user: user, role: role)

    redirect_to permit_path
  end

  def permissions_remove
    user_role = UserRole.find_by(id: clean_params[:permit_id])

    redirect_to permit_path, alert: "Cannot remove admin permissions." and return if user_role.role.name == "admin"

    user_role.destroy

    redirect_to permit_path
  end

  def assign_bridge
    bridge_office = BridgeOffice.find_by(office: clean_params[:bridge_office]) || BridgeOffice.create(office: clean_params[:bridge_office])
    if bridge_office.update(user_id: clean_params[:user_id])
      redirect_to bridge_path, notice: "Successfully assigned to bridge office."
    else
      redirect_to bridge_path, alert: "Unable to assign to bridge office."
    end
  end

  def assign_committee
    committee = Committee.create(name: clean_params[:committee], department: clean_params[:department], user_id: clean_params[:user_id])
    if committee.valid?
      redirect_to bridge_path, notice: "Successfully assigned to committee."
    else
      redirect_to bridge_path, alert: "Unable to assign to committee."
    end
  end

  def remove_committee
    @committee_id = clean_params[:id]
    if Committee.find_by(id: @committee_id)&.destroy
      flash[:notice] = "Successfully removed committee assignment."
      @do_remove = true
    else
      flash[:alert] = "Unable to remove committee assignment."
      @do_remove = false
    end
  end

  def assign_standing_committee
    y = clean_params[:term_start_at]["(1i)"]
    m = clean_params[:term_start_at]["(2i)"]
    d = clean_params[:term_start_at]["(3i)"]
    term_start = "#{y}-#{m}-#{d}"
    standing_committee = StandingCommitteeOffice.new(committee_name: clean_params[:committee_name], chair: clean_params[:chair], user_id: clean_params[:user_id], term_start_at: term_start, term_length: clean_params[:term_length])
    if standing_committee.save
      redirect_to bridge_path, notice: "Successfully assigned to standing committee."
    else
      redirect_to bridge_path, alert: "Unable to assign to standing committee."
    end
  end

  def remove_standing_committee
    @standing_committee_id = clean_params[:id]
    if StandingCommitteeOffice.find_by(id: @standing_committee_id)&.destroy
      flash[:notice] = "Successfully removed standing committee assignment."
      @do_remove = true
    else
      flash[:alert] = "Unable to remove from standing committee."
      @do_remove = false
    end
  end

  def register
    @event_id = clean_params[:id]
    unless Event.find_by(id: @event_id).allow_member_registrations
      flash[:alert] = "This course is not currently accepting registrations."
      render status: :unprocessable_entity and return
    end

    @registration = current_user.register_for(Event.find_by(id: @event_id))

    if @registration.valid?
      flash[:notice] = "Successfully registered!"
    else
      flash[:alert] = "We are unable to register you at this time."
      render status: :unprocessable_entity
    end
  end

  def cancel_registration
    @reg_id = clean_params[:id]
    r = Registration.find_by(id: @reg_id)
    @event_id = r&.event_id

    redirect_to root_path, status: :unprocessable_entity, alert: "You are not allowed to cancel that registration." and return unless (r.user == current_user) || current_user.permitted?(:course, :seminar, :event)

    @cancel_link = (r.user == current_user)

    if r&.destroy
      flash[:notice] = "Successfully cancelled registration!"
      RegistrationMailer.send_cancelled(r).deliver if @cancel_link
    else
      flash[:alert] = "We are unable to cancel your registration at this time."
      render status: :unprocessable_entity
    end
  end

  def lock
    user = User.find(params[:id])

    redirect_to users_path, alert: "Cannot lock an admin user." if user.permitted?(:admin)

    user.lock
    redirect_to users_path, notice: "Successfully locked user."
  end

  def unlock
    User.find(clean_params[:id]).unlock

    redirect_to users_path, notice: "Successfully unlocked user."
  end

  def import
    #
  end

  def do_import
    uploaded_file = clean_params[:import_file]

    if uploaded_file.content_type == "text/csv"
      flash[:alert] = nil
    else
      flash[:alert] = "You can only upload CSV files."
      render :import and return
    end

    import_path = "#{Rails.root}/tmp/#{Time.now.to_i}-users_import.csv"
    file = File.open(import_path, "w+")
    file.write(uploaded_file.read)
    file.close
    begin
      User.import(import_path)
      flash[:notice] = "Successfully imported user data."
      render :import
    rescue => e
      flash[:alert] = "Unable to import user data."
      render :import and return
      raise e
    end
  end

  def invite
    user = User.find_by(id: clean_params[:id])
    redirect_to users_path, alert: "User not found." if user.blank?

    user.invite!
    redirect_to users_path, notice: "Invitation sent!"
  end

  def invite_all
    redirect_to users_path, alert: "This action is currently disabled." and return unless ENV["ALLOW_BULK_INVITE"] == "true"

    users = User.unlocked.reject { |u| u.sign_in_count > 0 || u.email.match(/@example\.com/) || u.email.match(/bpsd9\.org/) }
    users.each { |user| user.invite! }
    redirect_to users_path, notice: "All new users have been sent invitations."
  end

  private
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
      invitable:          user.invitation_accepted_at.blank? && user.current_sign_in_at.blank? && !user.locked?,
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
      user.full_name.present? ? [user.full_name, user.id] : [user.email, user.id]
    end
  end

  def clean_params
    params.permit(:id, :user_id, :role, :permit_id, :committee, :department, :bridge_office, :type,
      :committee_name, :chair, :term_length, :import_file, term_start_at: ["(1i)", "(2i)", "(3i)"])
  end
end
