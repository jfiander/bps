# frozen_string_literal: true

# This is the base class for the separate controllers for each category:
# Events::EventsController
# Events::CoursesController
# Events::SeminarsController
#
# No route should point to this controller directly. Security is handled by each
# sub-controller, as appropriate.
class EventsController < ApplicationController
  include EventsHelper
  include Events::Preload
  include Events::Edit
  include Events::Update
  include Concerns::Application::RedirectWithStatus

  before_action :find_event, only: %i[copy edit expire]
  before_action :prepare_form, only: %i[new copy edit]
  before_action :check_for_blank, only: %i[create update]
  before_action :time_formats, only: %i[schedule catalog registrations show]
  before_action :preload_events, only: %i[schedule catalog registrations show]
  before_action :location_names, only: %i[new copy edit]
  before_action :set_create_path, only: %i[new copy]
  before_action :load_registrations, only: [:schedule], if: :user_signed_in?

  def schedule
    @events = get_events(event_type_param, :current)

    @current_user_permitted_event_type = current_user&.permitted?(event_type_param)

    return unless @current_user_permitted_event_type
    @registered_users = Registration.includes(:user).all.group_by(&:event_id)
    @expired_events = get_events(event_type_param, :expired)
  end

  def catalog
    @event_catalog = if event_type_param == 'course'
                       catalog_list.slice(
                         'public', 'advanced_grade', 'elective'
                       ).symbolize_keys
                     else
                       catalog_list[event_type_param]
                     end

    @current_user_permitted_event_type = current_user&.permitted?(event_type_param)
  end

  def registrations
    @current = Event.order(:start_at).current(event_type_param).with_registrations
    @expired = Event.order(:start_at).expired(event_type_param).with_registrations
  end

  def show
    @event = Event.find_by(id: clean_params[:id])
    return if event_not_found?

    @locations = Location.searchable
    @event_title = event_type_param.titleize
    @registration = Registration.new(event_id: clean_params[:id])

    return unless user_signed_in?
    reg = Registration.find_by(event_id: clean_params[:id], user: current_user)
    @registered = { reg.event_id => reg.id } if reg.present?
  end

  def new
    @event = Event.new
  end

  def copy
    @event = Event.new(@event.attributes)
    render :new
  end

  def create
    @event = Event.create(event_params)

    if @event.valid?
      flash[:notice] = 'Calendar event added. Add a repeat pattern, if needed.'
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
    @event = Event.find_by(id: event_params[:id])
    if @event.update(event_params)
      after_save_event(mode: :modified)
    else
      failed_to_save_event(mode: :modify)
    end
  end

  def expire
    redirect_with_status(send("#{event_type_param}s_path"), object: event_type_param, verb: 'expire') do
      @event.update(expires_at: Time.now)
    end
  end

  private

  def event_not_found?
    category = event_type_param == 'event' ? 'meeting' : event_type_param
    return false unless @event.blank? || @event.category != category

    flash[:notice] = "Couldn't find that #{event_type_param}."
    redirect_to send("#{event_type_param}s_path")
    true
  end
end
