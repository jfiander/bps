# frozen_string_literal: true

module Events
  module Edit
    # This module defines no public methods.
    def _; end

  private

    def event_params
      ep = params.require(:event).permit(
        %i[
          id event_type_id description cost member_cost usps_cost requirements summary location_id
          map_link start_at length_h length_m sessions flyer cutoff_at expires_at prereq_id
          allow_member_registrations repeat_pattern allow_public_registrations show_in_catalog
          delete_attachment online registration_limit advance_payment slug all_day activity_feed
          conference_id_cache link_override visible important_notes
        ]
      )

      filter_params(ep)
    end

    def filter_params(ep)
      ep.delete(:activity_feed) unless current_user.authorized_for_activity_feed?
      ep.delete(:conference_id_cache) unless current_user.permitted?(:admin)
      ep
    end

    def clean_params
      params.permit(:id, :notifications, :includes, :topics, :instructors, :locations, :slug)
    end

    def event_type_title_from(formatted)
      formatted.to_s.downcase.tr(' ', '_').to_sym
    end

    def after_save_event(mode: :added)
      update_attachments
      redirect_to(
        send("#{event_type_param}s_path"),
        success: "Successfully #{mode} #{event_type_param}."
      )
    end

    def failed_to_save_event(mode: :add)
      path = { add: :create, modify: :update }[mode]

      flash.now[:alert] = "Unable to #{mode} #{event_type_param}."
      flash.now[:error] = @event.errors.full_messages
      reset_vars_for_failed(mode, path)
      render :new
    end

    def find_event
      id = clean_params[:id] || event_params[:id]
      find_event_for(id)
      @event_types = EventType.all
      map_to_text = action_name != 'show'

      load_notifications(map_to_text: map_to_text) if @event&.meeting?

      return unless @event&.course? || @event&.seminar?

      load_includes(map_to_text: map_to_text)
      load_topics(map_to_text: map_to_text)
      load_instructors(map_to_text: map_to_text)
    end

    def find_event_for(id)
      events = Event.includes(:event_instructors, :instructors)
      events = events.visible unless current_user&.permitted?(event_type_param)
      @event = events.find_by(id: id)
    end

    def prepare_form
      @event_types = EventType.selector(event_type_param)
      @event_title = event_type_param.titleize
      @edit_mode = 'Add'
    end

    def location_names
      @locations = Location.all.map(&:display)
      @locations_grouped = Location.grouped
    end

    def set_create_path
      @submit_path = send("create_#{event_type_param}_path")
    end

    def check_for_blank
      return unless event_params['event_type_id'].blank?

      prepare_form
      reset_vars_for_blank
      flash[:alert] = "You must select a valid #{event_type_param} name."
      render :new
    end

    def reset_vars_for_blank
      @submit_path = send("create_#{event_type_param}_path")
      @event = Event.new(event_params)
      @course_topics = clean_params[:includes]
      @course_includes = clean_params[:topics]
      @instructors = clean_params[:instructors]
    end

    def reset_vars_for_failed(mode, path)
      @submit_path = send("#{path}_#{event_type_param}_path")
      @edit_mode = mode.to_s.titleize
      @event_types = EventType.selector(event_type_param)
      @event_title = event_type_param.titleize
    end
  end
end
