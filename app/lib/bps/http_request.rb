# frozen_string_literal: true

require 'net/http'
require 'net/https'

module BPS
  class HTTPRequest
    FORM_CONTENT_TYPE = 'application/x-www-form-urlencoded; charset=utf-8'

    class << self
      delegate :call, to: :new
    end

    def initialize(verbose: true)
      @verbose = verbose
    end

    def call
      uri = URI(self.class::REQUEST_URL)

      req = request(uri)
      req.add_field('Content-Type', FORM_CONTENT_TYPE)
      req.body = URI.encode_www_form(request_data)

      before_submit
      submit(uri, req)
    end

  private

    def before_submit
      # Override this method to add a callback before the actual submit
    end

    def client(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      http
    end

    def authorization(req)
      # Override this method to specify authorization
    end

    def request(uri)
      req = Net::HTTP::Post.new(uri)
      authorization(req)
      req
    end

    def request_data
      self.class::REQUEST_DATA
    end

    def submit(uri, req)
      print " [     ]  #{uri.to_s.truncate(120)}\r\033[3C" if @verbose
      result = client(uri).request(req)
      print "#{result.code}\n" if @verbose

      return result if result.code == '200'

      ErrorWithDetails.call(
        RequestError,
        'Response error received',
        code: result.code, request: req, uri: uri, body: result.response.body
      )
    end
  end
end
