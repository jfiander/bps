class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action { require_permission(params[:type]) }

  before_action :get_event,    only: [:copy, :edit, :destroy]
  before_action :prepare_form, only: [:new, :copy, :edit]

  def new
    @event = Event.new
    @submit_path = send("create_#{params[:type]}_path")
  end

  def copy
    @submit_path = send("create_#{params[:type]}_path")
    @event = Event.new(@event.attributes)
    render :new
  end

  def create
    @event = Event.create(event_params)
    if @event.valid?
      update_attachments
      redirect_to send("#{params[:type]}s_path"), notice: "Successfully added #{params[:type]}."
    else
      @submit_path = send("update_#{params[:type]}_path")
      @edit_mode = "Add"
      flash[:alert] = "Unable to add #{params[:type]}."
      render :new
    end
  end

  def edit
    @submit_path = send("update_#{params[:type]}_path")
    @edit_mode = "Modify"
    render :new
  end

  def update
    @event = Event.find_by(id: event_params[:id])
    flash = if @event.update(event_params)
      update_attachments
      redirect_to send("#{params[:type]}s_path"), notice: "Successfully updated #{params[:type]}."
    else
      @submit_path = send("update_#{params[:type]}_path")
      @edit_mode = "Modify"
      flash[:alert] = "Unable to update #{params[:type]}."
      render :edit
    end
  end

  def destroy
    flash = if @event.update(expires_at: Time.now)
      {notice: "Successfully expired #{params[:type]}."}
    else
      {alert: "Unable to expire #{params[:type]}."}
    end

    redirect_to send("#{params[:type]}s_path"), flash
  end

  private
  def event_params
    params.require(:event).permit(:id, :event_type_id, :description, :cost, :member_cost, :requirements, :location, :map_link,
      :start_at, :length, :sessions, :flyer, :expires_at, :prereq_id, :allow_member_registrations, :allow_public_registrations)
  end

  def update_params
    params.permit(:id, :includes, :topics, :instructors)
  end

  def event_type_title_from(formatted)
    formatted.to_s.downcase.gsub(" ", "_").to_sym
  end

  def get_event
    @event = Event.includes(:event_instructors, :instructors).find_by(id: update_params[:id])
    if @event.is_a_course?
      @course_includes = CourseInclude.where(course_id: @event.id).map(&:text).join("\n")
      @course_topics = CourseTopic.where(course_id: @event.id).map(&:text).join("\n")
    end

    if @event.is_a_course? || @event.is_a_seminar?
      @instructors = EventInstructor.where(event_id: @event.id).map(&:user).map { |u| "#{u.simple_name} / #{u.certificate}" }.join("\n")
    end
  end

  def prepare_form
    @event_types = EventType.send("#{params[:type]}s").map { |e| [e.display_title, e.id] }
    @event_title = params[:type].to_s.titleize
    @edit_mode = "Add"
  end

  def update_attachments
    return nil unless params[:type] == :course

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
          User.find_by(certificate: u.split("/").last.squish)
        else
          User.with_name(u).first
        end
        EventInstructor.create(event: @event, user: user)
      end

      CourseInclude.where(course: @event).where("updated_at < ?", clear_before_time).destroy_all
      CourseTopic.where(course: @event).where("updated_at < ?", clear_before_time).destroy_all
      EventInstructor.where(event: @event).where("updated_at < ?", clear_before_time).destroy_all
    end
  end
end
