# frozen_string_literal: true

module Api
  module V1
    class SlackController < ApplicationController
      def queue_update_from_slack
        api_token = ApiToken.find_by(key: slack_post_action['key'])

        if api_token.match?(slack_post_action['token'])
          AutomaticUpdateJob.perform_later(api_token.user_id, dryrun: false, via: 'Slack')
          render(json: { status: 'Queued automatic update.' }, status: :accepted)
        else
          render(json: { error: 'Invalid token.' }, status: :unauthorized)
        end
      rescue StandardError => e
        render(
          json: { error: 'Failed to queue automatic update.', message: e.message },
          status: :unprocessable_entity
        )
      end

    private

      def slack_post_action
        @slack_post_action ||= JSON.parse(JSON.parse(params[:payload])['actions'][0]['value'])
      end
    end
  end
end
