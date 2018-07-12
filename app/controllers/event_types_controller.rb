# frozen_string_literal: true

class EventTypesController < ApplicationController
  secure!(:event, :course, :seminar)

  title!('Event Types')

  ajax!(only: :refresh)

  def list
    @event_types = EventType.ordered.map do |et|
      { id: et.id, category: et.event_category, title: et.display_title }
    end

    %i[event course seminar].each do |role|
      next if current_user&.permitted?(role)
      @event_types.reject! { |et| et.send("#{role}?") }
    end

    @event_types = @event_types.group_by { |h| h[:category] }
  end

  def new
    @event_type = EventType.new
    @edit_action = 'Add'
    @submit_path = create_event_type_path
  end

  def create
    event_type_params[:title] = event_type_params[:title].underscore
    if (@event_type = EventType.create(event_type_params))
      redirect_to event_types_path, success: 'Successfully created event type.'
    else
      flash[:alert] = 'Unable to create event type.'
      flash[:errors] = @event_type.errors.full_messages
      redirect_to event_types_path
    end
  end

  def edit
    @event_type = EventType.find_by(id: update_params[:id])
    @edit_action = 'Modify'
    @submit_path = update_event_type_path
    render :new
  end

  def update
    @event_type = EventType.find_by(id: update_params[:id])

    if @event_type.update(event_type_params)
      redirect_to event_types_path, success: 'Successfully updated event type.'
    else
      flash[:alert] = 'Unable to update event type.'
      flash[:errors] = @event_type.errors.full_messages
      redirect_to event_types_path
    end
  end

  def remove
    if EventType.find_by(id: update_params[:id])&.destroy
      redirect_to event_types_path, success: 'Successfully removed event type.'
    else
      flash[:alert] = 'Unable to remove event type.'
      flash[:errors] = @event_type.errors.full_messages
      redirect_to event_types_path
    end
  end

  def refresh
    # html_safe: No user content
    article = refresh_params[:category] == 'event' ? 'an' : 'a'
    prompt = "Please select #{article} #{refresh_params[:category]} type"

    @new_event_types = (+'').html_safe
    @new_event_types << '<option value=\"\">'.html_safe
    @new_event_types << prompt
    @new_event_types << '</option>'.html_safe
    @new_event_types << '<option value=\"\"></option>'.html_safe

    event = Event.find_by(id: update_params[:id].to_i)

    EventType.selector(refresh_params[:category]).each do |title, id|
      @new_event_types << '<option value=\"'.html_safe
      @new_event_types << id.to_s
      @new_event_types << '\"'.html_safe
      @new_event_types << ' selected=\"selected\"'.html_safe if id == event&.event_type_id
      @new_event_types << '>'.html_safe
      @new_event_types << title.titleize
      @new_event_types << '</option>'.html_safe
    end
  end

  private

  def event_type_params
    params.require(:event_type).permit(:event_category, :title)
  end

  def update_params
    params.permit(:id)
  end

  def refresh_params
    params.permit(:category)
  end
end
