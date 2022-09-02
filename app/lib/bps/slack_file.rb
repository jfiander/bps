# frozen_string_literal: true

module BPS
  class SlackFile < BPS::HTTPRequest
    REQUEST_URL = 'https://slack.com/api/files.upload'

    def initialize(title, content, filetype = 'json', verbose: true)
      @title = title
      @content = content
      @filetype = filetype
      super(verbose: verbose)
    end

  private

    def format_json(json)
      JSON.pretty_generate(JSON.parse(json))
    end

    def request_data
      {
        content: format_json(@content),
        channels: channel_id,
        title: @title,
        filetype: @filetype
      }
    end

    def channel_id
      Rails.env.deployed? ? ENV['SLACK_CHANNEL_ID_NOTIFICATIONS'] : ENV['SLACK_CHANNEL_ID_TEST']
    end

    def authorization(req)
      req.add_field('Authorization', "Bearer #{ENV['SLACK_BOT_USER_TOKEN']}")
    end

    def before_submit
      puts "\nUploading results to Slack..."
    end
  end
end
