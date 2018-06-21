# Preview all emails at http://localhost:3000/rails/mailers/notifications_mailer
class NotificationsMailerPreview < ActionMailer::Preview
  def bridge
    NotificationsMailer.bridge(bridge_office, by: by, previous: previous)
  end

  def float_plan
    NotificationsMailer.float_plan(last_float_plan)
  end

  private

  def bridge_office
    BridgeOffice.last
  end

  def previous
    User.last
  end

  def by
    User.first
  end

  def last_float_plan
    FloatPlan.last
  end
end
