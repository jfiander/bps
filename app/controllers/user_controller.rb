class UserController < ApplicationController
  include UserMethods

  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, only: %i[auto_show auto_hide]
  skip_before_action :prerender_for_layout, only: %i[
    register cancel_registration remove_committee remove_standing_committee
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

  def register
    @event_id = clean_params[:id]
    @event = Event.find_by(id: @event_id)
    unless @event.allow_member_registrations
      flash.now[:alert] = 'This course is not currently accepting member registrations.'
      render status: :unprocessable_entity and return
    end

    unless @event.registerable?
      flash.now[:alert] = 'This course is no longer accepting registrations.'
      render status: :unprocessable_entity and return
    end

    @registration = current_user.register_for(Event.find_by(id: @event_id))

    if @registration.valid?
      flash[:success] = "Successfully registered!"
      RegistrationMailer.confirm(@registration).deliver
    elsif Registration.find_by(@registration.attributes.slice(:user_id, :event_id))
      flash.now[:notice] = 'You are already registered for this course.'
      render status: :unprocessable_entity
    else
      flash.now[:alert] = "We are unable to register you at this time."
      render status: :unprocessable_entity
    end
  end

  def cancel_registration
    @reg_id = clean_params[:id]
    r = Registration.find_by(id: @reg_id)
    @event_id = r&.event_id

    unless (r&.user == current_user) || current_user&.permitted?(:course, :seminar, :event)
      redirect_to root_path, status: :unprocessable_entity, alert: "You are not allowed to cancel that registration."
    end

    @cancel_link = (r&.user == current_user)

    if r&.destroy
      flash[:success] = "Successfully cancelled registration!"
      RegistrationMailer.cancelled(r).deliver if @cancel_link
    else
      flash.now[:alert] = "We are unable to cancel your registration at this time."
      render status: :unprocessable_entity
    end
  end

  def lock
    user = User.find(params[:id])

    redirect_to users_path, alert: "Cannot lock an admin user." if user.permitted?(:admin)

    user.lock
    redirect_to users_path, success: "Successfully locked user."
  end

  def unlock
    User.find(clean_params[:id]).unlock

    redirect_to users_path, success: "Successfully unlocked user."
  end

  def import
    #
  end

  def do_import
    uploaded_file = clean_params[:import_file]

    unless uploaded_file.content_type == 'text/csv'
      flash.now[:alert] = 'You can only upload CSV files.'
      render :import and return
    end

    import_path = "#{Rails.root}/tmp/#{Time.now.to_i}-users_import.csv"
    file = File.open(import_path, 'w+')
    file.write(uploaded_file.read)
    file.close
    begin
      User.import(import_path)
      flash.now[:success] = "Successfully imported user data."
      render :import
    rescue => e
      flash.now[:alert] = "Unable to import user data."
      render :import and return
      raise e
    end
  end

  def invite
    user = User.find_by(id: clean_params[:id])
    redirect_to users_path, alert: "User not found." if user.blank?

    user.invite!
    redirect_to users_path, success: "Invitation sent!"
  end

  def invite_all
    redirect_to users_path, alert: "This action is currently disabled." and return unless ENV["ALLOW_BULK_INVITE"] == "true"

    User.invitable.each(&:invite!)
    redirect_to users_path, success: "All new users have been sent invitations."
  end

  def assign_photo
    photo = clean_params[:photo]

    if User.find_by(id: clean_params[:id]).assign_photo(local_path: photo.path)
      flash[:success] = 'Successfully assigned profile photo!'
    else
      flash[:alert] = 'Unable to assign profile photo.'
    end

    dest_path = case clean_params[:redirect_to]
    when 'show'
      user_path(clean_params[:id])
    when 'list'
      users_path
    when 'bridge'
      bridge_path
    else
      users_path
    end
    redirect_to dest_path
  end

  def auto_show
    session[:auto_shows] ||= []
    unless session[:auto_shows].include? clean_params[:page_name]
      session[:auto_shows] << clean_params[:page_name]
    end
    head :ok
  end

  def auto_hide
    session[:auto_shows] ||= []
    if session[:auto_shows].include? clean_params[:page_name]
      session[:auto_shows].delete(clean_params[:page_name])
    end
    head :ok
  end

  private

  def can_view_profile?
    unless clean_params[:id].to_i == current_user.id ||
           current_user.permitted?(:admin)
      redirect_to user_path(current_user.id)
    end
  end
end
