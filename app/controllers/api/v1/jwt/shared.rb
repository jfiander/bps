# frozen_string_literal: true

module Api
  module V1
    module JWT
      module Shared
        def jwt_issuers
          ENV.select { |k, _| k.match?(/\AJWT_HMAC_KEY_/) }.each_with_object({}) do |(e, key), h|
            v = e.scan(/\AJWT_HMAC_KEY_(\d+)/)[0][0]
            h["bpsd9:#{Rails.env}:#{v}"] = key
          end
        end

        def version
          @version ||= self.class.name.split('::')[1].downcase
        end

        def format_access(access)
          access.is_a?(String) ? JSON.parse(access) : access
        end
      end

      class AccessRestrictionError < StandardError; end
    end
  end
end
