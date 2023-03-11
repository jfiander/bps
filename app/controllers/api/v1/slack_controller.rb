# frozen_string_literal: true

require 'net/http'
require 'net/https'

module Api
  module V1
    class SlackController < ApplicationController
      def queue_update_from_slack
        api_token = ApiToken.find_by(key: slack_post_action['key'])

        if api_token.match?(slack_post_action['token'])
          AutomaticUpdateJob.perform_later(api_token.user_id, dryrun: false, via: 'Slack')
          render(json: { status: 'Queued automatic update.' }, status: :accepted)
          respond_to_slack!
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

      def slack_post_payload
        @slack_post_payload ||= JSON.parse(params[:payload])
      end

      def slack_post_action
        @slack_post_action ||= JSON.parse(slack_post_payload['actions'][0]['value'])
      end

      def respond_to_slack!
        response_data = { 'delete_original' => 'true' }

        uri = URI(slack_post_payload['response_url'])
        req = Net::HTTP::Post.new(uri)
        req.add_field('Content-Type', 'application/json')
        req.body = URI.encode_www_form(response_data)
        result = client(uri).request(req)
        return if result.code == '200'

        BPS::ErrorWithDetails.call(
          BPS::RequestError,
          'Response error received',
          code: result.code, request: req.to_json, uri: uri, body: result.response.body
        )
      end

      def client(uri)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http
      end
    end
  end
end
