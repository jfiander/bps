class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action                           only: [:new_course,  :create_course]  { require_permission(:course) }
  before_action                           only: [:new_seminar, :create_seminar] { require_permission(:seminar) }
  before_action                           only: [:new_meeting, :create_meeting] { require_permission(:events) }
  before_action :preprocess_event_params, only: [:create_course, :create_seminar, :create_meeting]

  def new_course
    @event = Event.new(event_category: EventCategory.find_by(title: "advanced_grade"))
    @submit_path = create_course_path
    @course_types = EventType.where(event_category: EventCategory.courses).map(&:title).map(&:titleize)
  end

  def new_seminar
    @event = Event.new(event_type: EventType.find_by(title: "seminar"))
    @submit_path = create_seminar_path
    @seminar_types = EventType.where(event_category: EventCategory.seminars).map(&:title).map(&:titleize)
  end

  def new_meeting
    @event = Event.new(event_type: EventType.find_by(title: "meeting"))
    @submit_path = create_meeting_path
    @meeting_types = EventType.where(event_category: EventCategory.meetings).map(&:title).map(&:titleize)
  end

  def create_course
    if @event = Event.create(@event_params)
      redirect_to courses_path, notice: "Successfully added course."
    else
      render :new_course, alert: "Unable to add course."
    end
  end
  
  def create_seminar
    if @event = Event.create(@event_params)
      redirect_to seminars_path, notice: "Successfully added seminar."
    else
      render :new_seminar, alert: "Unable to add seminar."
    end
  end
  
  def create_meeting
    if @event = Event.create(@event_params)
      redirect_to events_path, notice: "Successfully added event."
    else
      render :new_event, alert: "Unable to add event."
    end
  end

  private
  def event_params
    params.require(:event).permit(:event_type, :description, :cost, :member_cost, :requirements,
      :location, :map_link, :start_at, :length, :sessions, :flyer, :expires_at, :prereq)
  end

  def event_type_title_from(formatted)
    formatted.downcase.gsub(" ", "_").to_sym
  end

  def preprocess_event_params
    event_type_id = EventType.find_by(title: event_type_title_from(event_params[:event_type])).id
    prereq_id = EventType.find_by(title: event_type_title_from(event_params[:prereq]))&.id
    @event_params = {event_type_id: event_type_id, prereq_id: prereq_id}.merge(event_params.except(:event_type, :prereq))
  end
end
