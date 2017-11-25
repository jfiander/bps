class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action                           only: [:new_course,  :create_course]  { require_permission(:course) }
  before_action                           only: [:new_seminar, :create_seminar] { require_permission(:seminar) }
  before_action                           only: [:new_meeting, :create_meeting] { require_permission(:events) }

  def new_event
    event_category_default_title = params[:type] == "course" ? "advanced_grade" : params[:type]
    @event = Event.new(event_category: EventCategory.find_by(title: params[:type]))
    @submit_path = send("create_#{params[:type]}_path")
    @event_types = EventType.where(event_category: EventCategory.send("#{params[:type]}s")).map(&:title).map(&:titleize)
    @event_title = params[:type].to_s.titleize
  end

  def create_event
    event_type_id = EventType.find_by(title: event_type_title_from(event_params[:event_type])).id
    prereq_id = EventType.find_by(title: event_type_title_from(event_params[:prereq]))&.id
    @event_params = {event_type_id: event_type_id, prereq_id: prereq_id}.merge(event_params.except(:event_type, :prereq))

    if @event = Event.create(@event_params)
      redirect_to send("#{params[:type]}s_path"), notice: "Successfully added #{params[:type]}."
    else
      render :new_course, alert: "Unable to add #{params[:type]}."
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
end
