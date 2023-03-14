# frozen_string_literal: true

class NotificationsMailerPreview < ApplicationMailerPreview
  def bridge
    NotificationsMailer.bridge(bridge_office, by: by, previous: previous)
  end

  def float_plan
    NotificationsMailer.float_plan(mock_float_plan)
  end

  def bilge
    NotificationsMailer.bilge(['editor@bpsd9.org', 'membership@bpsd9.org'], year: 2022, month: 11)
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
      user: User.first,
      name: 'Jack Member', phone: '123-456-7890',
      leave_at: 1.week.from_now,
      return_at: 2.weeks.from_now,
      alert_at: 2.weeks.from_now + 4.hours
    )
    @float_plan.id = -99
    @float_plan
  end
end
