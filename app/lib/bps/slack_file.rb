# frozen_string_literal: true

module BPS
  class SlackFile < HTTPRequest
    GET_UPLOAD_LINK_URL = 'https://slack.com/api/files.getUploadURLExternal'
    COMPLETE_UPLOAD_URL = 'https://slack.com/api/files.completeUploadExternal'

    def initialize(title, content, filetype = 'json', channel: :auto_updates, verbose: true)
      @title = title
      @content = content
      @filetype = filetype
      @channel = channel.to_s
      super(verbose: verbose)
    end

    def call
      Rails.logger.debug "\nRequesting Slack file upload URL..."
      upload_link, file_id = fetch_upload_link

      Rails.logger.debug "\nUploading results to Slack..."
      upload_file(upload_link)

      Rails.logger.debug "\nCompleting file uploading..."
      complete_upload(file_id)
    end

  private

    def fetch_upload_link
      upload_link_uri = URI(GET_UPLOAD_LINK_URL)
      upload_link_uri.query = URI.encode_www_form(upload_link_data)
      upload_link_req = get(upload_link_uri)
      upload_link_result = submit(upload_link_uri, upload_link_req)
      upload_json_response = JSON.parse(upload_link_result.response.body)

      upload_link = upload_json_response['upload_url']
      file_id = upload_json_response['file_id']
      [upload_link, file_id]
    end

    def upload_file(upload_link)
      upload_uri = URI(upload_link)
      upload_req = request(upload_uri)
      upload_req.body = json
      submit(upload_uri, upload_req).tap do |res|
        raise res.response.body unless res.response.body =~ /^OK /
      end
    end

    def complete_upload(file_id)
      complete_uri = URI(COMPLETE_UPLOAD_URL)
      complete_req = request(complete_uri)
      complete_req.add_field('Content-Type', FORM_CONTENT_TYPE)
      complete_req.body = URI.encode_www_form(destination_data(file_id))
      submit(complete_uri, complete_req).tap do |res|
        raise res.response.body unless JSON.parse(res.response.body)['ok']
      end
    end

    def get(uri)
      req = Net::HTTP::Get.new(uri)
      authorization(req)
      req
    end

    def json
      @json ||= JSON.pretty_generate(JSON.parse(@content))
    end

    def upload_link_data
      {
        filename: "MemberUpdates_#{Time.zone.now.strftime(TimeHelper::ISO_TIME_FORMAT)}",
        length: json.length
      }
    end

    def destination_data(file_id)
      {
        files: JSON.dump([{ id: file_id, title: @title }]),
        channel_id: channel_id
      }
    end

    def channel_id
      deployed_channel = "SLACK_CHANNEL_ID_#{@channel.upcase}"
      ENV[BPS::Application.deployed? ? deployed_channel : 'SLACK_CHANNEL_ID_TEST']
    end

    def authorization(req)
      req.add_field('Authorization', "Bearer #{ENV['SLACK_BOT_USER_TOKEN']}")
    end

    def before_submit
      Rails.logger.debug "\nUploading results to Slack..."
    end
  end
end
