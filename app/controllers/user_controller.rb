class UserController < ApplicationController
  before_action :authenticate_user!
  before_action                      except: [:current, :show, :permissions_index, :permissions_add, :permissions_remove, :assign_bridge, :assign_committee, :remove_committee] { require_permission(:admin) }
  before_action                        only: [                 :permissions_index, :permissions_add, :permissions_remove, :assign_bridge, :assign_committee, :remove_committee] { require_permission(:users) }
  before_action :get_users,            only: [:list]
  before_action :get_users_for_select, only: [:permissions_imdex, :assign_bridge, :assign_committee]
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
    @users = []

    User.where(locked_at: nil).each do |user|
      @users << user_hash(user)
    end

    User.where.not(locked_at: nil).each do |user|
      @users << user_hash(user)
    end

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
      redirect_to bridge_path, notice: "Successfully assigned committee."
    else
      redirect_to bridge_path, alert: "Unable to assign committee."
    end
  end

  def assign_committee
    committee = Committee.find_by(name: clean_params[:committee], department: clean_params[:department]) || Committee.create(name: clean_params[:committee], department: clean_params[:department])
    if committee.update(chair_id: clean_params[:user_id])
      redirect_to bridge_path, notice: "Successfully assigned committee."
    else
      redirect_to bridge_path, alert: "Unable to assign committee."
    end
  end

  def remove_committee
    if Committee.find_by(name: clean_params[:committee])&.destroy
      redirect_to bridge_path, notice: "Successfully removed committee."
    else
      redirect_to bridge_path, alert: "Unable to remove committee."
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

    if r&.destroy
      flash[:notice] = "Successfully cancelled registration!"
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

  private
  def get_users
    unlocked_users = User.all.select{ |u| !u.locked? }.sort { |a,b| a.id <=> b.id }
    locked_users   = User.all.select{ |u| u.locked? }.sort { |a,b| a.id <=> b.id }

    @users = unlocked_users + locked_users
  end

  def user_hash(user)
    {
      id:                 user.id,
      name:               "#{user.first_name} #{user.last_name}",
      email:              user.email,
      roles:              user.roles.map(&:name).flatten.uniq,
      current_login_at:   user.current_sign_in_at,
      current_login_from: user.current_sign_in_ip,
      locked:             user.locked?
    }
  end

  def get_users_for_select
    @users = User.all.to_a.map! do |user|
      return [user.email, user.id] if user.full_name.blank?
      [user.full_name, user.id]
    end
  end

  def clean_params
    params.permit(:id, :user_id, :role, :permit_id, :committee, :department, :bridge_office, :type)
  end
end
