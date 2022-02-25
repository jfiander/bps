# frozen_string_literal: true

require 'net/http'
require 'net/https'

require 'fileutils'

module AutomaticUpdate
  class DataRequest
    FORM_CONTENT_TYPE = 'application/x-www-form-urlencoded; charset=utf-8'

    def initialize(cookie_key = nil, verbose: false)
      @cookie_key = cookie_key
      @verbose = verbose
      FileUtils.mkdir_p(Rails.root.join('tmp/automatic_update'))
    end

    def call
      uri = URI(self.class::REQUEST_URL)

      req = request(uri)
      req.add_field('Content-Type', FORM_CONTENT_TYPE)
      req.body = URI.encode_www_form(self.class::REQUEST_DATA)

      submit(uri, req)
    end

    def download
      uri = URI(self.class::DOWNLOAD_URL)
      req = request(uri)
      result = submit(uri, req)

      path = Rails.root.join('tmp/automatic_update', "#{self.class.name.demodulize}.csv")
      File.open(path, 'w+') { |file| file.write(result.body) }
    end

  private

    def client(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      http
    end

    def request(uri)
      req = Net::HTTP::Post.new(uri)
      req.add_field('Cookie', "uspskey=#{@cookie_key}")
      req
    end

    def submit(uri, req)
      puts "URI:    #{uri}" if @verbose
      result = client(uri).request(req)
      puts "Result: #{result.code}\n\n" if @verbose

      return result if result.code == '200'

      Bugsnag.notify(
        DataRequestError.new(
          'Response error received',
          code: result.code, request: req, uri: uri, body: result.response.body
        )
      )
    end

    class DataRequestError < StandardError
      attr_reader :metadata

      def initialize(message, **metadata)
        super(message)
        @metadata = metadata
      end

      def bugsnag_meta_data
        {
          data_request: {
            code: metadata[:code],
            request: metadata[:request],
            uri: metadata[:uri],
            body: metadata[:body]
          }
        }
      end
    end
  end
end
