# frozen_string_literal: true

class PermissionsController < ApplicationController
  include User::Load

  secure!(:users)

  before_action :users_for_select, only: %i[index]

  def index
    @roles = Role.all.map(&:name)
    @roles.delete('admin')
    @roles.delete('users') unless current_user&.permitted?(:admin, strict: true, session: session)
    unless current_user&.permitted?(:education, session: session)
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

    user_role = UserRole.create!(user: user, role: role)
    permission_notification(user_role, :added, current_user)
    update_calendar_acl(user)

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
    update_calendar_acl(user_role.user)
    permission_notification(user_role, :removed, current_user)

    flash[:success] = "Successfully removed #{user_role.role.name} " \
                      "permission from #{user_role.user.simple_name}."
    redirect_to permit_path
  end

  def auto
    @auto ||= YAML.safe_load(
      File.read("#{Rails.root}/config/implicit_permissions.yml")
    )
  end

  private

  def clean_params
    params.permit(:user_id, :role, :permit_id)
  end

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
                   !current_user&.permitted?(:education, session: session)
    return true if role == 'users' &&
                   !current_user&.permitted?(:admin, strict: true, session: session)
    false
  end

  def permission_notification(user_role, mode, by)
    SlackNotification.new(
      type: :info, title: "Permission #{mode.to_s.titleize}",
      fallback: "A permission was #{mode}.",
      fields: [
        { title: 'User', value: user_role.user.full_name,  short: true },
        { title: 'Permission', value: user_role.role.name, short: true },
        { title: 'By', value: by.full_name, short: true }
      ]
    ).notify!
  end

  def calendar_id
    if ENV['ASSET_ENVIRONMENT'] == 'production'
      ENV['GOOGLE_CALENDAR_ID_GEN']
    else
      ENV['GOOGLE_CALENDAR_ID_TEST']
    end
  end

  def update_calendar_acl(user)
    method = user.permitted?(:calendar) ? :permit : :unpermit

    cal = GoogleCalendarAPI.new
    cal.authorize!
    cal.send(method, calendar_id, user)
  end
end
