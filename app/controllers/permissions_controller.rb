# frozen_string_literal: true

class PermissionsController < ApplicationController
  include UserMethods

  before_action :authenticate_user!
  before_action { require_permission(:users) }

  before_action :get_users_for_select, only: %i[index]

  def index
    @roles = Role.all.map(&:name)
    @roles.delete('admin')
    @roles.delete('users') unless current_user&.permitted?(:admin, strict: true)
    unless current_user&.permitted?(:education)
      @roles.delete('education')
      @roles.delete('course')
      @roles.delete('seminar')
    end

    respond_to do |format|
      format.html
    end
  end

  def add
    process_permissions_errors

    if flash[:alert].present?
      redirect_to permit_path
      return
    end

    user = User.find_by(id: clean_params[:user_id])
    role = Role.find_by(name: clean_params[:role])

    if UserRole.find_by(user: user, role: role)
      flash[:notice] = "#{user.simple_name} already has #{role.name} permissions."
      redirect_to permit_path
      return
    end

    UserRole.create!(user: user, role: role)

    flash[:success] = "Successfully added #{role.name} " \
                      "permission to #{user.simple_name}."
    redirect_to permit_path
  end

  def remove
    user_role = UserRole.find_by(id: clean_params[:permit_id])

    if user_role.role.name == 'admin'
      redirect_to permit_path, alert: 'Cannot remove admin permissions.'
      return
    end

    user_role.destroy

    flash[:success] = "Successfully removed #{user_role.role.name} " \
                      "permission from #{user_role.user.simple_name}."
    redirect_to permit_path
  end

  def auto
    @auto_permissions = YAML.safe_load(
      File.read("#{Rails.root}/config/implicit_permissions.yml")
    )
  end

  private

  def process_permissions_errors
    if clean_params[:user_id].blank?
      flash[:alert] = 'User was not selected.'
    elsif clean_params[:role].blank?
      flash[:alert] = 'Permission was not selected.'
    elsif restricted_permission?(clean_params[:role])
      flash[:alert] = 'Unable to add that permission.'
    end
  end

  def restricted_permission?(role)
    return true if role == 'admin'
    return true if role.in?(%w[education course seminar]) &&
                   !current_user&.permitted?(:education)
    return true if role == 'users' &&
                   !current_user&.permitted?(:admin, strict: true)
    false
  end
end
