class UserController < ApplicationController
  include UserMethods
  include User::Lock
  include User::Register
  include User::Import
  include User::Invite
  include User::Edit
  include User::Insignia

  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, only: %i[auto_show auto_hide]
  skip_before_action :prerender_for_layout, only: %i[
    register cancel_registration remove_committee remove_standing_committee
    no_member_registrations? no_registrations? register_for_event
    successfully_registered already_registered unable_to_register
    cannot_cancel_registration? successfully_cancelled unable_to_cancel
  ]

  before_action only: [:assign_photo] { require_permission(:admin) }
  before_action except: %i[current show register cancel_registration] do
    require_permission(:users)
  end
  before_action :can_view_profile?, only: [:show]
  before_action :find_user, only: [:show]

  before_action :get_users, only: [:list]
  before_action(
    :get_users_for_select,
    only: %i[permissions_index assign_bridge assign_committee]
  )
  before_action :time_formats, only: [:show]

  before_action { page_title('Users') }

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
           current_user.permitted?(:admin)
      redirect_to user_path(current_user.id)
    end
  end
end
