class NotificationsMailer < ApplicationMailer
  def bridge(bridge_office, by: nil, previous: nil)
    @bridge_office = bridge_office
    @by = by
    @previous = previous

    mail(to: 'dev@bpsd9.org', subject: 'Bridge Office Updated')
    bridge_slack_notification
  end

  private

  def user_descriptor(user)
    "#{user.full_name}\n#{user.certificate}, ##{user.id}"
  end

  def bridge_slack_notification
    SlackNotification.new(
      type: :info, title: 'Bridge Office Updated',
      fallback: 'A bridge office has been updated.',
      fields:  bridge_slack_fields(
        @bridge_office.title,
        @previous,
        @bridge_office.user,
        @by
      )
    ).notify!
  end

  def bridge_slack_fields(office, previous, new, by)
    [
      { 'title' => 'Office', 'value' => office, 'short' => true },
      { 'title' => 'Previous holder', 'value' => previous, 'short' => true },
      { 'title' => 'New holder', 'value' => new, 'short' => true },
      { 'title' => 'Updated by', 'value' => by, 'short' => true }
    ]
  end
end
