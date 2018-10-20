# frozen_string_literal: true

module EventTypes::Refresh
  def refresh
    # html_safe: No user content
    @new_event_types = (+'').html_safe
    @new_event_types << '<option value=\"\">'.html_safe
    @new_event_types << refresh_prompt
    @new_event_types << '</option>'.html_safe
    @new_event_types << '<option value=\"\"></option>'.html_safe

    event = Event.find_by(id: update_params[:id].to_i)

    EventType.selector(refresh_params[:category]).each do |title, id|
      add_option(title, id, event: event)
    end
  end

private

  def refresh_params
    params.permit(:category)
  end

  def refresh_prompt
    article = refresh_params[:category] == 'event' ? 'an' : 'a'
    "Please select #{article} #{refresh_params[:category]} type"
  end

  def add_option(title, id, event: nil)
    @new_event_types << '<option value=\"'.html_safe
    @new_event_types << id.to_s
    @new_event_types << '\"'.html_safe
    @new_event_types << ' selected=\"selected\"'.html_safe if id == event&.event_type_id
    @new_event_types << '>'.html_safe
    @new_event_types << (title.match?(/---/) ? title : title.titleize)
    @new_event_types << '</option>'.html_safe
  end
end
