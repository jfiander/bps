# frozen_string_literal: true

require 'fileutils'

module AutomaticUpdate
  class DataRequest < ::BPS::HTTPRequest
    FIELDS_TO_IGNORE = 7

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
      File.open(path, 'w+') { |file| file.write(result.body) }
    end

  private

    def request_data
      self.class::REQUEST_HEADER_DATA.merge(request_data_ignored_fields).merge(main_request_data)
    end

    def request_data_ignored_fields
      self.class::FIELDS_TO_IGNORE.times.each_with_object({}) { |i, h| h["fld#{i + 1}"] = 'N' }
    end

    def request_data_main_fields
      {}.tap do |hash|
        self.class::REQUEST_FIELD_NAMES.each_with_index do |field, index|
          id = FIELDS_TO_IGNORE + index + 1
          hash["fld#{id}"] = 'Y'
          hash["nam#{id}"] = field
        end
      end
    end

    def authorization(req)
      req.add_field('Cookie', "uspskey=#{@cookie_key}")
    end

    def before_submit
      puts "\nDownloading #{self.class.name.demodulize}..."
    end
  end
end
