class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action                only: [:new, :create, :edit, :update, :destroy] { require_permission(params[:type]) }
  before_action :get_event,    only: [:edit, :destroy]
  before_action :prepare_form, only: [:new, :edit]

  def new
    event_category_default_title = params[:type] == "course" ? "advanced_grade" : params[:type]
    @event = Event.new(event_category: EventCategory.find_by(title: params[:type]))
    @submit_path = send("create_#{params[:type]}_path")
    @edit_mode = "Add"
  end

  def create
    if @event = Event.create(event_params)
      redirect_to send("#{params[:type]}s_path"), notice: "Successfully added #{params[:type]}."
    else
      render :new, alert: "Unable to add #{params[:type]}."
    end
  end

  def edit
    @submit_path = send("update_#{params[:type]}_path")
    @edit_mode = "Modify"
    render :new
  end

  def update
    flash = if Event.find_by(id: event_params[:id]).update(event_params)
      {notice: "Successfully updated #{params[:type]}."}
    else
      {alert: "Unable to update #{params[:type]}."}
    end

    redirect_to send("#{params[:type]}s_path"), flash
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
    params.require(:event).permit(:id, :event_type_id, :description, :cost, :member_cost, :requirements,
      :location, :map_link, :start_at, :length, :sessions, :flyer, :expires_at, :prereq_id)
  end

  def destroy_params
    params.permit(:id)
  end

  def event_type_title_from(formatted)
    formatted.to_s.downcase.gsub(" ", "_").to_sym
  end

  def get_event
    @event = Event.find_by(id: destroy_params[:id])
  end

  def prepare_form
    @event_types = EventType.where(event_category: EventCategory.send("#{params[:type]}s")).map { |e| [e.title.titleize, e.id] }
    @event_title = params[:type].to_s.titleize
  end
end
