class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action only: [:new_course,  :create_course]  { require_permission(:courses) }
  before_action only: [:new_seminar, :create_seminar] { require_permission(:seminars) }
  before_action only: [:new_meeting, :create_meeting] { require_permission(:events) }

  def new_course
    @event = Event.new(event_type: EventType.find_by(name: "course"))
    @submit_path = "create_course"
  end

  def new_seminar
    @event = Event.new(event_type: EventType.find_by(name: "seminar"))
    @submit_path = "create_seminar"
  end

  def new_meeting
    @event = Event.new(event_type: EventType.find_by(name: "meeting"))
    @submit_path = "create_meeting"
  end

  def create_course
    if @event.save
      redirect_to courses_path, notice: "Successfully added course."
    else
      redirect_to new_course_path(@event), alert: "Unable to add course."
    end
  end
  
  def create_seminar
    if @event.save
      redirect_to seminars_path, notice: "Successfully added seminar."
    else
      redirect_to new_seminar_path(@event), alert: "Unable to add seminar."
    end
  end
  
  def create_meeting
    if @event.save
      redirect_to events_path, notice: "Successfully added event."
    else
      redirect_to new_event_path(@event), alert: "Unable to add event."
    end
  end
end
