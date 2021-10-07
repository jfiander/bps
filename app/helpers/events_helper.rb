# frozen_string_literal: true

module EventsHelper
  def reg_override_icon(reg)
    options = reg_override_options(reg)
    icon = FA::Icon.p(
      'file-invoice-dollar',
      style: reg_override_style(reg), css: options[:css], title: options[:title]
    )
    reg.paid? ? icon : link_to(override_cost_path(reg.payment.token)) { icon }
  end

  def reg_override_style(reg)
    reg.override_cost.present? ? :solid : :duotone
  end

  def reg_override_verb(reg)
    reg.override_cost.present? ? 'Update' : 'Set'
  end

  def reg_override_options(reg)
    if reg.paid?
      { title: 'Registration has already been paid', css: 'gray' }
    else
      { title: "#{reg_override_verb(reg)} override cost", css: 'green' }
    end
  end

  def event_flags(event)
    content_tag(:div, class: 'event-flags') do
      # Education Flags
      concat event_catalog_flag(event)

      # General Flags
      concat event_activity_flag(event)
      concat event_not_visible_flag(event)

      # Non-Education Flags
      concat event_committees_flag(event)
    end
  end

  def event_catalog_flag(event)
    return unless @current_user_permitted_event_type && event.show_in_catalog

    content_tag(:div, class: 'catalog') do
      concat FA::Icon.p('stars', style: :duotone, fa: :fw)
      concat content_tag(:small, 'In catalog')
    end
  end

  def event_activity_flag(event)
    return unless @current_user_permitted_event_type && event.activity_feed

    content_tag(:div, class: 'catalog') do
      concat FA::Icon.p('stream', style: :duotone, fa: :fw)
      concat content_tag(:small, 'Available for activity feed')
    end
  end

  def event_not_visible_flag(event)
    return unless @current_user_permitted_event_type && !event.visible

    content_tag(:div, class: 'invisible-flag') do
      concat FA::Icon.p('eye-slash', style: :duotone, fa: :fw)
      concat content_tag(
        :small, 'Not visible',
        title: 'This event is not visible to members or the public. Only editors can see it.'
      )
    end
  end

  def event_committees_flag(event)
    return unless @current_user_permitted_event_type && event.event_type.event_type_committees.any?

    committees = event.event_type.event_type_committees.map do |etc|
      content_tag(:small, etc.committee)
    end.uniq
    title = 'Will notify relevant bridge officers and the listed committees'

    content_tag(:div, class: 'catalog', title: title) do
      concat FA::Icon.p('envelope', style: :duotone, fa: :fw)
      concat safe_join(committees, tag(:br))
    end
  end
end
