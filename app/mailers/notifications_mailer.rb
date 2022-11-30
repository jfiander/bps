# frozen_string_literal: true

class NotificationsMailer < ApplicationMailer
  def bridge(bridge_office, by: nil, previous: nil)
    @bridge_office = bridge_office
    @by = by
    @previous = previous
    @to_list = ['dev@bpsd9.org']

    bridge_slack_notification
    mail(to: @to_list, subject: 'Bridge Office Updated')
  end

  def float_plan(float_plan)
    @float_plan = float_plan
    @to_list = float_plan_to_list
    mail(to: @to_list, subject: 'Float Plan Submitted')
  end

  def bilge(emails, year:, month:)
    @to_list = emails.empty? ? ['dev@bpsd9.org'] : emails
    @year = year
    @month = month

    mail(to: @to_list, subject: 'Bilge Chatter Posted')
    bilge_slack_notification
  end

private

  def user_descriptor(user)
    user.present? ? "#{user.full_name(html: false)}\n#{user.certificate}, ##{user.id}" : 'TBD'
  end

  def bridge_slack_notification
    SlackNotification.new(
      channel: :notifications, type: :info, title: 'Bridge Office Updated',
      fallback: 'A bridge office has been updated.',
      fields: {
        'Office' => @bridge_office.title,
        'Previous holder' => user_descriptor(@previous),
        'New holder' => user_descriptor(@bridge_office.user),
        'Updated by' => user_descriptor(@by)
      }
    ).notify!
  end

  def bilge_slack_notification
    SlackNotification.new(
      channel: :notifications, type: :info, title: 'Bilge Chatter Posted',
      fallback: 'A Bilge Chatter issue has been posted.',
      fields: {
        'Year' => @year,
        'Issue' => BilgeFile.issues[@month],
        'Link' => bilge_url(year: @year, month: @month)
      }
    ).notify!
  end

  def float_plan_monitor_emails
    Committee.get(
      :administrative, 'Float Plan Monitor'
    ).map { |c| c.user.email }
  end

  def float_plan_to_list
    if float_plan_monitor_emails.present?
      float_plan_monitor_emails
    else
      ['"No Monitors" <dev@bpsd9.org>']
    end
  end
end
