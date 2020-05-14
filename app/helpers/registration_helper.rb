# frozen_string_literal: true

module RegistrationHelper
  def pay_reg_link(reg)
    return paid_icon if reg.paid?
    return unless reg.payable?

    ActionController::Base.helpers.link_to(
      Rails.application.routes.url_helpers.pay_path(token: reg.payment.token)
    ) do
      FA::Icon.p('credit-card', style: :duotone, title: 'Pay for registration', fa: 'fw')
    end
  end

  def cancel_reg_link(reg)
    return if reg.paid?

    confirm = "Are you sure you want to cancel your registration for #{reg.event.display_title}" \
    " on #{reg.event.start_at.strftime(ApplicationController::SHORT_TIME_FORMAT)}?"

    ActionController::Base.helpers.link_to(
      Rails.application.routes.url_helpers.cancel_registration_path(id: reg.id),
      method: :delete, remote: true, class: 'red', id: "event_#{reg.event_id}",
      data: { confirm: confirm }
    ) { FA::Icon.p('minus-square', style: :duotone) }
  end

private

  def paid_icon
    FA::Layer.p(
      [
        { name: 'credit-card', options: { style: :duotone, css: :gray } },
        { name: 'check', options: { style: :regular, css: :green, grow: 12 } }
      ],
      title: 'Paid – Thank you!'
    )
  end
end
