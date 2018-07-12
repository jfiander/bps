# frozen_string_literal: true

module Locations::Refresh
  def refresh
    # html_safe: No user content
    @new_locations = (+'').html_safe
    @new_locations << '<option value=\"\">Please select a location</option>'.html_safe
    @new_locations << '<option value=\"\"></option>'.html_safe
    @new_locations << '<option value=\"TBD\">TBD</option>'.html_safe

    event = Event.find_by(id: update_params[:id].to_i)

    Location.searchable.each do |id, l|
      add_option(l, id, event: event)
    end
  end

  private

  def add_option(l, id, event: nil)
    @new_locations << '<option value=\"'.html_safe
    @new_locations << id.to_s
    @new_locations << '\"'.html_safe
    @new_locations << ' selected=\"selected\"'.html_safe if id == event&.location_id
    @new_locations << '>'.html_safe
    @new_locations << l[:name].strip
    @new_locations << '</option>'.html_safe
  end
end
