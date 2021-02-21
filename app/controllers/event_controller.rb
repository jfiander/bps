# frozen_string_literal: true

# This is the base class for the separate controllers for each category:
# Events::EventsController
# Events::CoursesController
# Events::SeminarsController
#
# No route should point to this controller directly. Security is handled by each
# sub-controller, as appropriate.
class EventController < ApplicationController
  include EventsHelper
  include Events::Preload
  include Events::Edit
  include Events::Update
  include Concerns::Application::RedirectWithStatus

  before_action :find_event, only: %i[show copy edit update expire archive remind book unbook]
  before_action :prepare_form, only: %i[new copy edit]
  before_action :check_for_blank, only: %i[create update]
  # before_action :preload_events, only: %i[schedule catalog registrations show]
  before_action :location_names, only: %i[new copy edit]
  before_action :set_create_path, only: %i[new copy]
  before_action :load_registrations, only: %i[schedule], if: :user_signed_in?
  before_action :event_not_found?, only: %i[show]
  before_action :block_multiple_reminders, only: %i[remind]

  def schedule
    @events = current
    @locations ||= Location.searchable

    @current_user_permitted_event_type = current_user&.permitted?(
      event_type_param, session: session
    )

    return unless @current_user_permitted_event_type

    @registered_users = Registration.includes(:user).all.group_by(&:event_id)
    @expired_events = expired
  end

  def catalog
    @event_catalog = load_catalog
    @current_user_permitted_event_type = current_user&.permitted?(
      event_type_param, session: session
    )
  end

  def registrations
    @current = current.with_registrations
    @expired = expired.with_registrations
  end

  def show
    @locations = Location.searchable
    @event_title = event_type_param.titleize
    @registration = Registration.new(event_id: clean_params[:id])
    return unless user_signed_in?

    reg = Registration.find_by(event_id: clean_params[:id], user: current_user)
    @registered = { reg.event_id => reg.id } if reg.present?
  end

  def slug
    event = Event.find_by(slug: clean_params[:slug].downcase)
    return redirect_to(event.link) if event.present?

    redirect_to(root_path, alert: 'Unknown short URL.')
  end

  def new
    @event = Event.new
  end

  def copy
    @event = Event.new(
      @event.attributes.merge(
        show_in_catalog: false, start_at: nil, cutoff_at: nil, expires_at: nil,
        slug: nil, online: false
      )
    )
    render :new
  end

  def create
    @event = Event.create(event_params)

    if @event.valid?
      flash[:notice] = 'Calendar event added.'
      after_save_event(mode: :added)
    else
      failed_to_save_event(mode: :add)
    end
  end

  def edit
    @submit_path = send("update_#{event_type_param}_path")
    @edit_mode = 'Modify'
    render :new
  end

  def update
    if @event.update(event_params)
      after_save_event(mode: :modified)
    else
      failed_to_save_event(mode: :modify)
    end
  end

  def expire
    redirect_with_status(
      send("#{event_type_param}s_path"), object: event_type_param, verb: 'expire'
    ) do
      @event.expire!
    end
  end

  def archive
    redirect_with_status(
      send("#{event_type_param}s_path"), object: event_type_param, verb: 'archive'
    ) do
      @event.archive!
    end
  end

  def remind
    @event.remind!
    flash[:success] = 'Successfully sent reminder emails.'
    redirect_to send("#{event_type_param}s_path")
  end

  def book
    @event.book!
    flash[:success] = "Successfully booked #{event_type_param}."
    redirect_to send("#{event_type_param}s_path")
  end

  def unbook
    @event.unbook!
    flash[:success] = "Successfully unbooked #{event_type_param}."
    redirect_to send("#{event_type_param}s_path")
  end

private

  def load_catalog
    return catalog_list unless event_type_param == 'course'

    catalog_list.group_by { |e| e.event_type.event_category }.symbolize_keys
  end

  def event_not_found?
    category = event_type_param == 'event' ? 'meeting' : event_type_param
    return unless @event.blank? || @event.category != category

    flash[:notice] = "Couldn't find that #{event_type_param}."
    redirect_to send("#{event_type_param}s_path")
  end

  def block_multiple_reminders
    return unless @event.reminded?

    flash[:alert] = "Reminders already sent for that #{event_type_param}."
    redirect_to send("#{event_type_param}s_path")
  end

  def current
    @current ||= Event.include_details.displayable.current.for_category(event_type_param)
  end

  def expired
    @expired ||= Event.include_details.displayable.expired.for_category(event_type_param)
  end

  def catalog_list
    Event.where(show_in_catalog: true)
  end
end
