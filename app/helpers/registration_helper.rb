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

  def cancel_reg_link(reg, event: nil)
    return if reg.paid?

    event ||= reg.event

    confirm = "Are you sure you want to cancel your registration for #{event.display_title} " \
              "on #{event.start_at.strftime(TimeHelper::SHORT_TIME_FORMAT)}?"

    ActionController::Base.helpers.link_to(
      Rails.application.routes.url_helpers.cancel_registration_path(id: reg.id),
      method: :delete, remote: true, class: 'red', id: "event_#{event.id}",
      data: { confirm: confirm }
    ) { FA::Icon.p('minus-square', style: :duotone) }
  end

  def subscribe_reg_link(reg)
    return unless reg&.user&.phone_c&.present?

    if reg.subscription_arn.present?
      unsubscribe_link(reg.id)
    else
      subscribe_link(reg.id)
    end
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

  def subscribe_link(id)
    ActionController::Base.helpers.link_to(
      Rails.application.routes.url_helpers.subscribe_path(id: id),
      remote: true, method: :post, class: 'gray', id: "subscription_#{id}",
      title: 'Receive SMS notifications'
    ) do
      FA::Icon.p('bell', style: :duotone, fa: 'fw')
    end
  end

  def unsubscribe_link(id)
    ActionController::Base.helpers.link_to(
      Rails.application.routes.url_helpers.unsubscribe_path(id: id),
      remote: true, method: :post, class: 'green', id: "subscription_#{id}",
      title: 'Cancel SMS notifications'
    ) do
      FA::Icon.p('bell-on', style: :duotone, fa: 'fw')
    end
  end
end
