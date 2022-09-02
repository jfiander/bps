# frozen_string_literal: true

module BPS
  class RequestError < ErrorWithMetadata
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
