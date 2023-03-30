# frozen_string_literal: true

class NotificationsMailer < ApplicationMailer
  def bridge(bridge_office, by: nil, previous: nil)
    @bridge_office = bridge_office
    @by = by
    @previous = previous
    @to_list = ['dev@bpsd9.org']

    mail(to: @to_list, subject: 'Bridge Office Updated')
  end

  def float_plan(float_plan)
    @float_plan = float_plan
    @to_list = float_plan_to_list
    mail(to: @to_list, subject: 'Float Plan Submitted')
  end

  def bilge(emails, year:, month:)
    @to_list = emails.empty? ? ['dev@bpsd9.org'] : emails
    @year = year.to_i
    @month = month.to_i

    mail(to: @to_list, subject: 'Bilge Chatter Posted')
  end

private

  def float_plan_monitor_emails
    Committee.get(
      :administrative, 'Float Plan Monitor'
    ).map { |c| c.user.email }
  end

  def float_plan_to_list
    (float_plan_monitor_emails.presence || ['"No Monitors" <dev@bpsd9.org>'])
  end
end
