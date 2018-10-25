# frozen_string_literal: true

module EventsActionLinksHelper
  def event_action_link(event, path, **options)
    return if options.key?(:if) && !options[:if]
    return if options.key?(:expired) && options[:expired] != event&.expired?

    options = process_options(options)
    icon = event_action_link_icon(options)

    generate_event_action_link(event, path, icon, options)
  end

private

  def process_options(options)
    options = event_action_link_defaults(options[:css]).merge(options)
    confirm = options.delete(:confirm)
    options[:data][:confirm] = confirm if confirm.present?
    options
  end

  def event_action_link_defaults(css)
    {
      icon: '', text: '', class: "control #{css}",
      confirm: '', data: {}, icon_options: { fa: :fw, style: :regular }
    }
  end

  def event_action_link_icon(options)
    FA::Icon.p(options[:icon], options.delete(:icon_options)) + options[:text].titleize
  end

  def generate_event_action_link(event, path, icon, options)
    if path.present? && path.match?(/_path/)
      link_to(send(path, event), **options) { icon }
    elsif path.present?
      link_to(path, **options) { icon }
    else
      icon
    end
  end
end