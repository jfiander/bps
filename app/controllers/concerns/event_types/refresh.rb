# frozen_string_literal: true

module EventTypes
  module Refresh
    def refresh
      # html_safe: Text is sanitized before display
      @new_event_types = <<~HTML.html_safe
        "<option value=\\"\\">#{refresh_prompt}</option>" +
        "<option value=\\"\\"></option>" +
      HTML

      event = Event.find_by(id: update_params[:id].to_i)

      @new_event_types << new_options(event).html_safe
    end

  private

    def refresh_params
      params.permit(:category)
    end

    def refresh_prompt
      article = refresh_params[:category] == 'event' ? 'an' : 'a'
      "Please select #{article} #{refresh_params[:category]} type"
    end

    def new_options(event)
      EventType.selector(refresh_params[:category], key: true).map do |group, options|
        option_tags = options.map { |t, id| add_option(t, id, event: event) }.join(" +\n")
        add_optgroup(group, option_tags)
      end.join(" +\n")
    end

    def add_optgroup(group, option_tags)
      "\"<optgroup label=\\\"#{group}\\\">\" +\n#{option_tags} +\n\"</optgroup>\""
    end

    def add_option(title, id, event: nil)
      selected = ' selected=\"selected\"' if id == event&.event_type_id
      title = title.match?(/---/) ? title : title.titleize

      "\"<option value=\\\"#{id}\\\"#{selected}>#{sanitize(title)}</option>\""
    end
  end
end
