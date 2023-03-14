# frozen_string_literal: true

module AutomaticUpdate
  class LoginRequest < DataRequest
    REQUEST_URL = 'https://www.usps.org/x/validate.cgi?/cgi-bin-nat/tools/infobeg.cgi'
    REQUEST_DATA = {
      'cert' => ENV.fetch('AUTOMATIC_UPDATE_CERTIFICATE', nil),
      'pin'  => ENV.fetch('AUTOMATIC_UPDATE_PASSWORD', nil)
    }.freeze

  private

    def request_data
      REQUEST_DATA
    end

    def request(uri)
      Net::HTTP::Post.new(uri) # No cookie sent on login
    end
  end
end
