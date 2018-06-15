# frozen_string_literal: true

module Events::Edit
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

  def clean_params
    params.permit(:id, :includes, :topics, :instructors, :locations)
  end

  def event_type_title_from(formatted)
    formatted.to_s.downcase.tr(' ', '_').to_sym
  end

  def after_save_event(mode: :added)
    update_attachments
    redirect_to(
      send("#{params[:type]}s_path"),
      success: "Successfully #{mode} #{params[:type]}."
    )
  end

  def failed_to_save_event(mode: :add)
    path = { add: :create, modify: :update }[mode]

    flash.now[:alert] = "Unable to #{mode} #{params[:type]}."
    flash.now[:error] = @event.errors.full_messages
    @submit_path = send("#{path}_#{params[:type]}_path")
    @edit_mode = mode.to_s.titleize
    @event_types = EventType.selector(params[:type])
    @event_title = params[:type].to_s.titleize
    render :new
  end

  def find_event
    @event = Event.includes(:event_instructors, :instructors)
                  .find_by(id: clean_params[:id])

    return unless @event.course? || @event.seminar?

    load_includes
    load_topics
    load_instructors
  end

  def prepare_form
    @event_types = EventType.selector(params[:type])
    @event_title = params[:type].to_s.titleize
    @edit_mode = 'Add'
  end

  def location_names
    @locations = Location.all.map(&:display)
  end

  def set_create_path
    @submit_path = send("create_#{params[:type]}_path")
  end

  def check_for_blank
    return unless event_params['event_type_id'].blank?

    prepare_form
    @submit_path = send("create_#{params[:type]}_path")
    @event = Event.new(event_params)
    @course_topics = clean_params[:includes]
    @course_includes = clean_params[:topics]
    @instructors = clean_params[:instructors]
    flash[:alert] = "You must select a valid #{params[:type]} name."
    render :new
  end
end
