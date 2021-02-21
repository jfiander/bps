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
end
