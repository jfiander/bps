# frozen_string_literal: true

class UserController < ApplicationController
  include User::Load
  include User::Lock
  include User::Register
  include User::RequestSchedule
  include User::Import
  include User::Invite
  include User::Edit
  include User::Insignia
  include User::Instructors

  secure!
  secure!(:admin, only: :assign_photo)
  secure!(:users, except: %i[current show register cancel_registration instructors])
  secure!(:education, only: :instructors)

  before_action :can_view_profile?, only: [:show]
  before_action :can_view_profile?, only: [:certificate]
  before_action :find_user, only: [:show]
  before_action :load_users, only: [:list]
  before_action(
    :users_for_select,
    only: %i[permissions_index assign_bridge assign_committee]
  )

  title!('Users', except: %i[show instructors])
  title!('User', only: :show)
  title!('Instructors', only: :instructors)

  def show
    @registrations = Registration.for_user(@user.id).current.reject do |r|
      r.event.blank?
    end

    @profile_title = @user.id == current_user.id ? 'Current' : 'Selected'

    insignia

    respond_to do |format|
      format.html
      format.json { render json: @user }
    end
  end

  def list
    respond_to do |format|
      format.html
      format.json { render json: @users }
    end
  end

  def certificate
    @user = User.find_by(id: clean_params[:id])

    @membership_date = @user.membership_date&.strftime('%Y-%m-%d') || clean_params[:member_date]
    @last_mm = @user.last_mm&.strftime('%Y') || clean_params[:last_mm]

    respond_to do |format|
      format.pdf do
        send_file(
          EducationCertificatePDF.for(
            @user, membership_date: @membership_date, last_mm: @last_mm
          ), disposition: :inline
        )
      end

      format.html do
        redirect_to user_certificate_path(id: @user.id, format: :pdf)
      end
    end
  end

  private

  def can_view_profile?
    unless clean_params[:id].to_i == current_user.id ||
           current_user&.permitted?(:admin)
      redirect_to user_path(current_user.id)
    end
  end

  def can_view_certificate?
    unless clean_params[:id].to_i == current_user.id ||
           current_user&.permitted?(:admin)
      redirect_to user_certificate_path(current_user.id)
    end
  end

  def clean_params
    params.permit(
      :id, :type, :page_name, :import_file, :lock_missing, :photo, :redirect_to,
      :member_date, :last_mm, :key, :only
    )
  end
end
