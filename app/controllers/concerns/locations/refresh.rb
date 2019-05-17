# frozen_string_literal: true

module Locations::Refresh
  def refresh
    # html_safe: Text is sanitized before display
    new_locations = <<~HTML
      "<option value=\\\"\\\">Please select a location</option>" +
      "<option value=\\\"\\\"></option>" +
      "<optgroup label=\\\"TBD\\\"><option value=\\\"TBD\\\">TBD</option></optgroup>" +
    HTML

    @locations = Location.grouped
    event = Event.find_by(id: update_params[:id].to_i)

    new_locations += %w[Favorites Others].map { |group| add_group(group, event) }.join(' + ')

    @new_locations = new_locations.html_safe
  end

private

  def new_options
    Location.searchable.map { |id, l| add_option(l, id) }
  end

  def add_optgroup(group)
    "\"<optgroup label=\\\"#{group}\\\">\" +\n#{yield} +\n\"</optgroup>\""
  end

  def add_option(l, id, event: nil)
    selected = ' selected=\"selected\"' if id == event&.location_id
    "\"<option value=\\\"#{id}\\\"#{selected}>#{sanitize(l.strip)}</option>\""
  end

  def add_group(key, event)
    add_optgroup(key) do
      @locations[key].map { |loc| add_option(loc[0], loc[1], event: event) }.join(' + ')
    end
  end
end
