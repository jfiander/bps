# frozen_string_literal: true

class PermissionsController < ApplicationController
  include User::Load

  secure!(:users)

  before_action :find_roles, only: %i[index]
  before_action :restrict_roles, only: %i[index]
  before_action :users_for_select, only: %i[index]
  before_action :find_user_role, only: %i[destroy]
  before_action :block_remove_admin, only: %i[destroy]
  before_action :process_permissions_errors, only: %i[create]
  before_action :find_user_and_role, only: %i[create]
  before_action :block_duplicate_permissions, only: %i[create]

  def index
    respond_to(&:html)
  end

  def create
    user_role = UserRole.create!(user: @user, role: @role)
    permission_notification(user_role, :added, current_user)
    update_calendar_acl(@user)

    flash[:success] = "Successfully added #{@role.name} " \
                      "permission to #{@user.simple_name}."
    redirect_to permissions_path
  end

  def destroy
    @user_role.destroy
    update_calendar_acl(@user_role.user)
    permission_notification(@user_role, :removed, current_user)

    flash[:success] = "Successfully removed #{@user_role.role.name} " \
                      "permission from #{@user_role.user.simple_name}."
    redirect_to permissions_path
  end

  def auto
    @auto ||= YAML.safe_load(Rails.root.join('config/implicit_permissions.yml').read)
  end

private

  def find_roles
    @roles = Role.all.map(&:name)
  end

  def restrict_roles
    @roles.delete('admin')

    @roles.delete('users') unless current_user&.permitted?(:admin, strict: true)

    return if current_user&.permitted?(:education)

    @roles.delete('education')
    @roles.delete('course')
    @roles.delete('seminar')
  end

  def find_user_and_role
    @user = User.find_by(id: clean_params[:user_id])
    @role = Role.find_by(name: clean_params[:role])
  end

  def block_duplicate_permissions
    return unless UserRole.find_by(user: @user, role: @role)

    flash[:notice] = "#{@user.simple_name} already has #{@role.name} permissions."
    redirect_to permissions_path
  end

  def find_user_role
    @user_role = UserRole.find_by(id: clean_params[:id])
  end

  def block_remove_admin
    return unless @user_role.role.name == 'admin'

    redirect_to permissions_path, alert: 'Cannot remove admin permissions.'
  end

  def clean_params
    params.permit(:user_id, :role, :id)
  end

  def process_permissions_errors
    missing_selection
    restricted_role
  end

  def missing_selection
    if clean_params[:user_id].blank?
      redirect_to permissions_path, alert: 'User was not selected.'
      return
    end

    return if clean_params[:role].present?

    redirect_to permissions_path, alert: 'Permission was not selected.'
  end

  def restricted_role
    return unless restricted_permission?(clean_params[:role])

    redirect_to permissions_path, alert: 'Unable to add that permission.'
  end

  def restricted_permission?(role)
    return true if role == 'admin'
    return true if restricted_education(role)
    return true if restricted_admin(role)

    false
  end

  def restricted_education(role)
    role.in?(%w[education course seminar]) &&
      !current_user&.permitted?(:education)
  end

  def restricted_admin(role)
    role.in?(%w[users]) && !current_user&.permitted?(:admin, strict: true)
  end

  def permission_notification(user_role, mode, by)
    SlackNotification.new(
      channel: :notifications, type: :info, title: "Permission #{mode.to_s.titleize}",
      fallback: "A permission was #{mode}.",
      fields: [
        { title: 'User', value: user_role.user.full_name,  short: true },
        { title: 'Permission', value: user_role.role.name, short: true },
        { title: 'By', value: by.full_name, short: true }
      ]
    ).notify!
  end

  def calendar_id
    return ENV['GOOGLE_CALENDAR_ID_GEN'] if Rails.env.production?

    ENV['GOOGLE_CALENDAR_ID_TEST']
  end

  def update_calendar_acl(user)
    method = user.permitted?(:calendar) ? :permit : :unpermit

    GoogleAPI::Configured::Calendar.new(calendar_id).send(method, user)
  end
end
