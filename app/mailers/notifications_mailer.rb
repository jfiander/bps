class NotificationsMailer < ApplicationMailer
  def bridge(bridge_office, by: nil, previous: nil)
    @bridge_office = bridge_office
    @by = by
    @previous = previous

    mail(to: 'dev@bpsd9.org', subject: 'Bridge Office Updated')
    bridge_slack_notification
  end

  def float_plan(float_plan)
    @float_plan = float_plan
    to = if float_plan_monitor_emails.present?
           float_plan_monitor_emails
         else
           ['"No Monitors" <dev@bpsd9.org>']
         end
    mail(to: to, subject: 'Float Plan Submitted')
  end

  private

  def user_descriptor(user)
    "#{user.full_name}\n#{user.certificate}, ##{user.id}"
  end

  def bridge_slack_notification
    SlackNotification.new(
      type: :info, title: 'Bridge Office Updated',
      fallback: 'A bridge office has been updated.',
      fields: {
        'Office' => @bridge_office.title,
        'Previous holder' => @previous.full_name,
        'New holder' => @bridge_office.user.full_name,
        'Updated by' => @by.full_name
      }
    ).notify!
  end

  def float_plan_monitor_emails
    Committee.get(:administrative, 'float_plan_monitor').map { |c| c.user.email }
  end
end
