# frozen_string_literal: true

require 'fileutils'

module AutomaticUpdate
  class DataRequest < ::BPS::HTTPRequest
    def initialize(cookie_key = nil, verbose: false)
      @cookie_key = cookie_key
      FileUtils.mkdir_p(Rails.root.join('tmp/automatic_update'))
      super(verbose: verbose)
    end

    def download
      uri = URI(self.class::DOWNLOAD_URL)
      req = request(uri)
      result = submit(uri, req)

      path = Rails.root.join('tmp/automatic_update', "#{self.class.name.demodulize}.csv")
      File.write(path, result.body)
    end

  private

    def authorization(req)
      req.add_field('Cookie', "uspskey=#{@cookie_key}")
    end

    def before_submit
      puts "\nDownloading #{self.class.name.demodulize}..."
    end
  end
end
