# frozen_string_literal: true

class NotificationsMailerPreview < ActionMailer::Preview
  def bridge
    NotificationsMailer.bridge(bridge_office, by: by, previous: previous)
  end

  def float_plan
    NotificationsMailer.float_plan(last_float_plan)
  end

private

  def bridge_office
    user = User.new(email: "#{SecureRandom.hex(16)}@example.com")
    BridgeOffice.new(office: 'Executive', user: user)
  end

  def previous
    User.new(email: "#{SecureRandom.hex(16)}@example.com")
  end

  def by
    User.new(email: "#{SecureRandom.hex(16)}@example.com")
  end

  def last_float_plan
    FloatPlan.new
  end
end
