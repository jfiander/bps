# frozen_string_literal: true

module OTWTrainings
  module Public
    def public; end

    def public_request
      OTWMailer.jumpstart(otw_public_params).deliver
      jumpstart_slack_notification(otw_public_params)
    end

  private

    def otw_public_params
      params.permit(:name, :email, :phone, :details, :availability)
    end

    def jumpstart_slack_notification(options)
      SlackNotification.new(
        channel: :notifications, type: :info, title: 'OTW Training Requested',
        fallback: 'Someone has requested OTW training.',
        fields: {
          'Training' => 'JumpStart',
          'Requested by' => options[:name],
          'Email' => options[:email]
        }
      ).notify!
    end
  end
end
