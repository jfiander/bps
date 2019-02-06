# frozen_string_literal: true

class NotificationsMailerPreview < ApplicationMailerPreview
  def bridge
    NotificationsMailer.bridge(bridge_office, by: by, previous: previous)
  end

  def float_plan
    NotificationsMailer.float_plan(mock_float_plan)
  end

private

  def bridge_office
    BridgeOffice.new(office: 'Executive', user: user)
  end

  def previous
    user
  end

  def by
    user
  end

  def mock_float_plan
    @float_plan ||= FloatPlan.new(
      name: 'Jack Member', phone: '123-456-7890',
      leave_at: Time.now + 1.week,
      return_at: Time.now + 2.weeks,
      alert_at: Time.now + 2.weeks + 4.hours
    )
    @float_plan.id = -99
    @float_plan
  end
end
