# frozen_string_literal: true

class EventTypesController < ApplicationController
  include EventTypes::Refresh
  include Concerns::Application::RedirectWithStatus

  secure!(:admin, :education, strict: true)

  title!('Event Types')

  ajax!(only: :refresh)

  def list
    @event_types = EventType.ordered.map do |et|
      { id: et.id, category: et.event_category, title: et.display_title }
    end

    clean_event_types

    @event_types = @event_types.group_by { |h| h[:category] }
  end

  def new
    @event_type = EventType.new
    @edit_action = 'Add'
    @submit_path = create_event_type_path

    @event_types = EventType.all
    return if current_user&.permitted?(:admin, strict: true)
    @event_types = @event_types.where.not(event_category: 'meeting')
  end

  def create
    event_type_params[:title] = event_type_params[:title].underscore
    if restricted?
      redirect_to event_types_path, alert: 'You cannot add that type of event.'
      return
    end

    redirect_with_status(event_types_path, object: 'event_type', verb: 'create') do
      @event_type = EventType.create(event_type_params)
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

    redirect_with_status(event_types_path, object: 'event_type', verb: 'update') do
      @event_type.update(event_type_params)
    end
  end

  def remove
    redirect_with_status(event_types_path, object: 'event_type', verb: 'remove') do
      EventType.find_by(id: update_params[:id])&.destroy
    end
  end

  private

  def event_type_params
    params.require(:event_type).permit(:event_category, :title)
  end

  def update_params
    params.permit(:id)
  end

  def restricted?
    !current_user&.permitted?(:admin, strict: true) &&
      event_type_params[:event_category] == 'meeting'
  end

  def clean_event_types
    %w[event course seminar].each do |role|
      next if current_user&.permitted?(role)
      if role == 'course'
        @event_types.reject! { |et| et[:category].in? %w[advanced_grade elective public] }
      elsif role == 'event'
        @event_types.reject! { |et| et[:category] == 'meeting' }
      else
        @event_types.reject! { |et| et[:category] == role }
      end
    end
  end
end
