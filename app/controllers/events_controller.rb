class EventsController < ApplicationController
  include EventsHelper

  before_action :authenticate_user!, except: [:schedule, :catalog, :show]
  before_action                      except: [:schedule, :catalog, :show, :locations, :remove_location] { require_permission(params[:type]) }

  before_action :get_event,       only: [:copy, :edit, :expire]
  before_action :prepare_form,    only: [:new, :copy, :edit]
  before_action :check_for_blank, only: [:create, :update]

  before_action :time_formats,    only: [:schedule, :catalog, :show]
  before_action :preload_events,  only: [:schedule, :catalog, :show]

  before_action { page_title("#{params[:type].to_s.titleize}s") }

  def schedule
    @events = get_events(params[:type], :current)
    @registered = Registration.includes(:user).where(user_id: current_user.id).map { |r| {r.event_id => r.id} }.reduce({}, :merge) if user_signed_in?

    @current_user_permitted_event_type = current_user&.permitted?(params[:type])

    if current_user&.permitted?(params[:type])
      @registered_users = Registration.includes(:user).all.group_by { |r| r.event_id }
      @expired_events = get_events(params[:type], :expired)
    end
  end

  def catalog
    @event_catalog = if params[:type] == :course
      @catalog.slice('public', 'advanced_grade', 'elective').symbolize_keys
    else
      @catalog[params[:type].to_s]
    end
  end

  def show
    @event = Event.find_by(id: show_params[:id])
    if @event.blank? || @event.category != params[:type]
      flash[:notice] = "Couldn't find that #{params[:type]}."
      redirect_to send("#{params[:type]}s_path")
      return
    end
    @locations = Location.searchable
    @event_title = params[:type].to_s.titleize
    @registration = Registration.new(event_id: show_params[:id])
    if user_signed_in?
      reg = Registration.find_by(
        event_id: show_params[:id],
        user: current_user
      )

      @registered = { reg.event_id => reg.id }
    end
  end

  def new
    @event = Event.new
    @locations = Location.all.map(&:display)
    @submit_path = send("create_#{params[:type]}_path")
  end

  def copy
    @event = Event.new(@event.attributes)
    @locations = Location.all.map(&:display)
    @submit_path = send("create_#{params[:type]}_path")
    render :new
  end

  def create
    @event = Event.create(event_params)

    if @event.valid?
      update_attachments
      redirect_to send("#{params[:type]}s_path"), success: "Successfully added #{params[:type]}."
    else
      @submit_path = send("update_#{params[:type]}_path")
      @edit_mode = "Add"
      flash.now[:alert] = "Unable to add #{params[:type]}."
      flash.now[:error] = @event.errors.full_messages
      render :new
    end
  end

  def edit
    @locations = Location.all.map(&:display)
    @submit_path = send("update_#{params[:type]}_path")
    @edit_mode = "Modify"
    render :new
  end

  def update
    @event = Event.find_by(id: event_params[:id])
    if @event.update(event_params)
      update_attachments
      redirect_to send("#{params[:type]}s_path"), success: "Successfully updated #{params[:type]}."
    else
      @submit_path = send("update_#{params[:type]}_path")
      @edit_mode = "Modify"
      flash.now[:alert] = "Unable to update #{params[:type]}."
      flash.now[:error] = @event.errors.full_messages
      render :edit
    end
  end

  def expire
    if @event.update(expires_at: Time.now)
      redirect_to send("#{params[:type]}s_path"), success: "Successfully expired #{params[:type]}."
    else
      redirect_to send("#{params[:type]}s_path"), alert: "Unable to expire #{params[:type]}."
    end
  end

  private
  def event_params
    params.require(:event).permit(
      %i[
        id event_type_id description cost member_cost requirements
        location_id map_link start_at length sessions flyer
        cutoff_at expires_at prereq_id allow_member_registrations
        allow_public_registrations show_in_catalog
      ]
    )
  end

  def location_params
    params.permit(:locations)
  end

  def update_params
    params.permit(:id, :includes, :topics, :instructors)
  end

  def show_params
    params.permit(:id)
  end

  def event_type_title_from(formatted)
    formatted.to_s.downcase.gsub(" ", "_").to_sym
  end

  def get_event
    @event = Event.includes(:event_instructors, :instructors).find_by(id: update_params[:id])
    if @event.course?
      @course_includes = CourseInclude.where(course_id: @event.id).map(&:text).join("\n")
      @course_topics = CourseTopic.where(course_id: @event.id).map(&:text).join("\n")
    end

    if @event.course? || @event.seminar?
      @instructors = EventInstructor.where(event_id: @event.id).map(&:user).map { |u| "#{u.simple_name} / #{u.certificate}" }.join("\n")
    end
  end

  def prepare_form
    @event_types = EventType.selector(params[:type])
    @event_title = params[:type].to_s.titleize
    @edit_mode = "Add"
  end

  def update_attachments
    return nil unless params[:type].in? [:course, :seminar]

    Event.transaction do
      clear_before_time = Time.now

      update_params[:includes].split("\n").map(&:squish).each do |i|
        CourseInclude.create(course: @event, text: i)
      end

      update_params[:topics].split("\n").map(&:squish).each do |t|
        CourseTopic.create(course: @event, text: t)
      end

      update_params[:instructors].split("\n").map(&:squish).each do |u|
        user = if u.match(/\//)
          User.find_by(certificate: u.split("/").last.squish.upcase)
        else
          User.with_name(u).first
        end
        EventInstructor.create(event: @event, user: user) if user.present?
      end

      CourseInclude.where(course: @event).where("updated_at < ?", clear_before_time).destroy_all
      CourseTopic.where(course: @event).where("updated_at < ?", clear_before_time).destroy_all
      EventInstructor.where(event: @event).where("updated_at < ?", clear_before_time).destroy_all
    end
  end

  def check_for_blank
    if event_params["event_type_id"].blank?
      prepare_form
      @submit_path = send("create_#{params[:type]}_path")
      @event = Event.new(event_params)
      @course_topics = update_params[:includes]
      @course_includes = update_params[:topics]
      @instructors = update_params[:instructors]
      flash[:alert] = "You must select a valid #{params[:type]} name."
      render :new
    end
  end
end
