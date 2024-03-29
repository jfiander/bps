# frozen_string_literal: true

class OTWMailer < ApplicationMailer
  def requested(otw_training_user)
    @otw = otw_training_user.otw_training
    @user = otw_training_user.user
    @to_list = to_list

    slack_notification(@otw.name)
    mail(to: @to_list, subject: 'On-the-Water training requested')
  end

  def jumpstart(options = {})
    @options = options
    @to_list = to_list

    slack_notification('Jump Start')
    mail(to: @to_list, subject: 'Jump Start training requested')
  end

private

  def to_list
    list = ['seo@bpsd9.org', 'aseo@bpsd9.org']

    committees = Committee.get(:educational, 'On-the-Water Training')
    list << committees&.map { |c| c&.user&.email }
  end

  def slack_notification(name)
    SlackNotification.new(
      channel: :notifications, type: :info, title: 'OTW Training Requested',
      fallback: 'Someone has requested OTW training.',
      fields: {
        'Training' => name,
        'Requested by' => @user&.full_name || @options[:name],
        'Email' => @user&.email || @options[:email]
      }
    ).notify!
  end
end
