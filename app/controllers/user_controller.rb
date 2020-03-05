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
  include User::Receipts

  secure!(except: %i[add_registrants collect_payment])
  secure!(
    :users, except: %i[current show register cancel_registration instructors certificate]
  )

  before_action :can_view_profile?, only: %i[show certificate]
  before_action :profile_title, only: :show

  title!('Users', except: %i[show instructors])
  title!('User', only: :show)
  title!('Instructors', only: :instructors)
  title!('Receipts', only: :receipts)

  def show
    @registrations = Registration.for_user(@user.id).current.reject { |r| r.event.blank? }

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
    @last_mm = @user.last_mm_year&.strftime('%Y') || clean_params[:last_mm]

    respond_to do |format|
      format.pdf { send_certificate }

      format.html do
        redirect_to user_certificate_path(id: @user.id, format: :pdf)
      end
    end
  end

private

  def profile_title
    @profile_title = @user.id == current_user.id ? 'Current' : 'Selected'
  end

  def can_view_profile?
    unless clean_params[:id].to_i == current_user.id ||
           current_user&.permitted?(:admin, session: session)
      redirect_to user_path(current_user.id)
    end
  end

  def can_view_certificate?
    unless clean_params[:id].to_i == current_user.id ||
           current_user&.permitted?(:admin, session: session)
      redirect_to user_certificate_path(current_user.id)
    end
  end

  def membership_date
    @user.membership_date&.strftime('%Y-%m-%d') || clean_params[:member_date]
  end

  def send_certificate
    send_file(
      BpsPdf::EducationCertificate.for(
        @user, membership_date: membership_date, last_mm: @last_mm
      ), disposition: :inline
    )
  end

  def clean_params
    params.permit(
      :id, :type, :page_name, :import_file, :lock_missing, :photo, :redirect_to,
      :member_date, :last_mm, :key, :only, :token
    )
  end
end
