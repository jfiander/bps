# frozen_string_literal: true

module Locations::Refresh
  def refresh
    # html_safe: Text is sanitized before display
    @new_locations = <<~HTML.html_safe
      "<option value=\\\"\\\">Please select a location</option>" +
      "<option value=\\\"\\\"></option>" +
      "<option value=\\\"TBD\\\">TBD</option>" +
    HTML

    event = Event.find_by(id: update_params[:id].to_i)

    @new_locations << new_options(event).html_safe
  end

private

  def new_options(event)
    Location.searchable.map { |id, l| add_option(l, id, event: event) }.join(" +\n")
  end

  def add_option(l, id, event: nil)
    selected = ' selected=\"selected\"' if id == event&.location_id
    "\"<option value=\\\"#{id}\\\"#{selected}>#{sanitize(l[:name].strip)}</option>\""
  end
end
