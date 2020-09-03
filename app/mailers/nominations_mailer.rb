# frozen_string_literal: true

class NominationsMailer < ApplicationMailer
  def nomination(nominator, award, nominee, description, target)
    @nominator = nominator
    @award = award
    @nominee = nominee # Simple string, not a user object
    @description = description
    @target = target
    @to_list = to_list

    slack_notification if @target == 'Executive Committee'
    mail(to: @to_list, subject: 'Award nomination submitted')
  end

private

  def to_list
    {
      'SEO' => ['seo@bpsd9.org'],
      'Commander' => ['commander@bpsd9.org'],
      'Executive Committee' => ['excom@bpsd9.org']
    }[@target]
  end

  def slack_notification
    SlackNotification.new(
      channel: :excom, type: :info, title: 'Award Nomination Submitted',
      fallback: 'Someone has submitted a nomination for an ExCom award.',
      fields: {
        'Nominator' => @nominator.full_name,
        'Award' => @award,
        'Nominee' => @nominee
      }
    ).notify!
  end
end
