# frozen_string_literal: true

class EventsController < ApplicationController
  include EventsHelper
  include EventsMethods

  before_action :authenticate_user!, except: %i[schedule catalog show]
  before_action except: %i[schedule catalog show locations remove_location] do
    require_permission(params[:type])
  end

  before_action :find_event,         only: %i[copy edit expire]
  before_action :prepare_form,       only: %i[new copy edit]
  before_action :check_for_blank,    only: %i[create update]

  before_action :time_formats,       only: %i[schedule catalog registrations show]
  before_action :preload_events,     only: %i[schedule catalog registrations show]
  before_action :location_names,     only: %i[new copy edit]
  before_action :set_create_path,    only: %i[new copy]
  before_action :load_registrations, only: [:schedule], if: :user_signed_in?

  before_action { page_title("#{params[:type].to_s.titleize}s") }

  def schedule
    @events = get_events(params[:type], :current)

    @current_user_permitted_event_type = current_user&.permitted?(params[:type])

    return unless @current_user_permitted_event_type
    @registered_users = Registration.includes(:user).all.group_by(&:event_id)
    @expired_events = get_events(params[:type], :expired)
  end

  def catalog
    @event_catalog = if params[:type] == :course
                       catalog_list.slice(
                         'public', 'advanced_grade', 'elective'
                       ).symbolize_keys
                     else
                       catalog_list[params[:type].to_s]
                     end

    @current_user_permitted_event_type = current_user&.permitted?(params[:type])
  end

  def registrations
    @current = Event.order(:start_at).current(params[:type]).with_registrations
    @expired = Event.order(:start_at).expired(params[:type]).with_registrations
  end

  def show
    @event = Event.find_by(id: clean_params[:id])
    if @event.blank? || @event.category != params[:type]
      flash[:notice] = "Couldn't find that #{params[:type]}."
      redirect_to send("#{params[:type]}s_path")
      return
    end

    @locations = Location.searchable
    @event_title = params[:type].to_s.titleize
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
      after_save_event(mode: :added)
    else
      failed_to_save_event(mode: :add)
    end
  end

  def edit
    @submit_path = send("update_#{params[:type]}_path")
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
    if @event.update(expires_at: Time.now)
      flash[:success] = "Successfully expired #{params[:type]}."
    else
      flash[:alert] = "Unable to expire #{params[:type]}."
    end

    redirect_to send("#{params[:type]}s_path")
  end
end
