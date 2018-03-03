class PermissionsController < ApplicationController
  include UserMethods

  before_action :authenticate_user!
  before_action { require_permission(:users) }

  before_action :get_users_for_select, only: %i[index]

  def index
    @roles = Role.all.map(&:name)
    @roles.delete("admin")
    @roles.delete('user') unless current_user&.permitted?(:admin)

    respond_to do |format|
      format.html
    end
  end

  def add
    redirect_to permit_path, alert: "User was not selected." and return if clean_params[:user_id].blank?
    redirect_to permit_path, alert: "Role was not selected." and return if clean_params[:role].blank?
    redirect_to permit_path, alert: "Cannot add admin permissions." and return if clean_params[:role] == "admin"
    redirect_to permit_path, alert: 'Must be an admin to add user permissions.' and return if clean_params[:role] == 'user' && !current_user&.permitted?(:admin)

    user = User.find_by(id: clean_params[:user_id])
    role = Role.find_by(name: clean_params[:role])

    redirect_to permit_path, notice: '#{user.simple_name} already has #{role.name} permissions.' and return if UserRole.find_by(user: user, role: role)

    UserRole.create!(user: user, role: role)

    redirect_to permit_path, success: "Successfully added #{role.name} permission to #{user.simple_name}."
  end

  def remove
    user_role = UserRole.find_by(id: clean_params[:permit_id])

    redirect_to permit_path, alert: "Cannot remove admin permissions." and return if user_role.role.name == "admin"

    user_role.destroy

    redirect_to permit_path, success: "Successfully removed #{user_role.role.name} permission from #{user_role.user.simple_name}."
  end

  def auto
    @auto_permissions = YAML.safe_load(
      File.read("#{Rails.root}/config/implicit_permissions.yml")
    )
  end
end
