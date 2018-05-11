class NotificationsMailer < ApplicationMailer
  def bridge(bridge_office, by: nil, previous: nil)
    @bridge_office = bridge_office
    @by = by
    @previous = previous

    mail(to: 'dev@bpsd9.org', subject: 'Bridge Office Updated')
  end
end
