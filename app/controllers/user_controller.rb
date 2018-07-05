# frozen_string_literal: true

class UserController < ApplicationController
  include User::Load
  include User::Lock
  include User::Register
  include User::Import
  include User::Invite
  include User::Edit
  include User::Insignia

  secure!
  secure!(:admin, only: :assign_photo)
  secure!(:users, except: %i[current show register cancel_registration])

  ajax!(
    only: %i[
      register cancel_registration no_member_registrations? no_registrations?
      register_for_event successfully_registered already_registered
      unable_to_register cannot_cancel_registration? successfully_cancelled
      unable_to_cancel
    ]
  )

  before_action :can_view_profile?, only: [:show]
  before_action :find_user, only: [:show]
  before_action :load_users, only: [:list]
  before_action(
    :users_for_select,
    only: %i[permissions_index assign_bridge assign_committee]
  )
  before_action :time_formats, only: [:show]

  title!('Users', except: :show)
  title!('User', only: :show)

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

  private

  def can_view_profile?
    unless clean_params[:id].to_i == current_user.id ||
           current_user&.permitted?(:admin)
      redirect_to user_path(current_user.id)
    end
  end

  def clean_params
    params.permit(:id, :type, :page_name, :import_file, :photo, :redirect_to)
  end
end
