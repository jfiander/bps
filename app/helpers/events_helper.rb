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
      color = reg.promo_code.present? ? 'purple' : 'gray'
      { title: 'Registration has already been paid', css: color }
    else
      { title: "#{reg_override_verb(reg)} override cost", css: 'green' }
    end
  end

  def event_flags(event)
    content_tag(:div, class: 'chiclets') do
      # Education Flags
      concat event_catalog_flag(event)

      # General Flags
      concat event_activity_flag(event)
      concat event_not_visible_flag(event)
      concat event_quiet_flag(event)

      # Non-Education Flags
      concat event_committees_flag(event)
    end
  end

  def event_catalog_flag(event)
    return unless @current_user_permitted_event_type && event.show_in_catalog

    title = 'This event is shown in the catalog.'

    content_tag(:div, class: 'birmingham-blue', title: title) do
      concat FA::Icon.p('stars', style: :duotone, fa: :fw)
      concat content_tag(:small, 'Catalog')
    end
  end

  def event_activity_flag(event)
    return unless @current_user_permitted_event_type && event.activity_feed

    title = 'This event is available for display in the activity feed.'

    content_tag(:div, class: 'birmingham-blue', title: title) do
      concat FA::Icon.p('stream', style: :duotone, fa: :fw)
      concat content_tag(:small, 'Activity Feed')
    end
  end

  def event_not_visible_flag(event)
    return unless @current_user_permitted_event_type && !event.visible

    title = 'This event is not visible to members or the public. Only editors can see it.'

    content_tag(:div, class: 'red', title: title) do
      concat FA::Icon.p('eye-slash', style: :duotone, fa: :fw)
      concat content_tag(:small, 'Not Visible')
    end
  end

  def event_quiet_flag(event)
    return unless @current_user_permitted_event_type && event.quiet

    title = 'This event is not displayed in the schedule. Direct links can still access it.'

    content_tag(:div, class: 'purple', title: title) do
      concat FA::Icon.p('face-shush', style: :duotone, fa: :fw)
      concat content_tag(:small, 'Quiet')
    end
  end

  def event_committees_flag(event)
    return unless @current_user_permitted_event_type && event.event_type.event_type_committees.any?

    title = 'Will notify the listed committee in addition to the relevant bridge officers.'

    safe_join(
      event.event_type.event_type_committees.uniq(&:committee).map do |etc|
        content_tag(:div, class: 'green', title: title) do
          concat FA::Icon.p('envelope', style: :duotone, fa: :fw)
          concat content_tag(:small, etc.committee)
        end
      end
    )
  end

  def event_selections_indented(event)
    [].tap do |combined|
      event.event_selections.map do |selection|
        combined << selection.description
        selection.event_options.each do |option|
          combined << "  #{option.name}"
        end
      end
    end.join("\n")
  end
end
