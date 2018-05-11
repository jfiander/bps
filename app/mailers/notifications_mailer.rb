class NotificationsMailer < ApplicationMailer
  def bridge(bridge_office, by: nil, previous: nil)
    @bridge_office = bridge_office
    @by = by
    @previous = previous

    mail(to: 'dev@bpsd9.org', subject: 'Bridge Office Updated')
    SlackNotifications.notify(
      type: :info,
      data: {
        'fallback' => 'A bridge office has been updated.',
        'title'    => 'Bridge Office Updated',
        'fields' => [
          {
            'title' => 'Office',
            'value' => @bridge_office.title,
            'short' => true
          },
          {
            'title' => 'Previous holder',
            'value' => user_descriptor(@previous),
            'short' => true
          },
          {
            'title' => 'New holder',
            'value' => user_descriptor(@bridge_office.user),
            'short' => true
          },
          {
            'title' => 'Updated by',
            'value' => user_descriptor(@by),
            'short' => true
          }
        ]
      }
    )
  end

  private

  def user_descriptor(user)
    "#{user.full_name}\n#{user.certificate}, ##{user.id}"
  end
end
