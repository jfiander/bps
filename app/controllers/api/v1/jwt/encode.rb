# frozen_string_literal: true

module Api
  module V1
    module JWT
      module Encode
        include Shared

        def create_jwt(data)
          data[:access] ||= default_access
          jwt = ::JWT.encode(jwt_payload(data), default_jwt_secret, 'HS512')

          NewJWT.new('JWT', jwt, jwt_expires_at)
        end

        def default_jwt_issuer
          jwt_issuers.max_by { |iss, _key| iss.split(':').last.to_i }
        end

        def default_jwt_secret
          default_jwt_issuer[1]
        end

        def jwt_expires_at
          @jwt_expires_at ||= Time.now + 15.minutes
        end

        def jwt_payload(data)
          {
            data: data,
            exp: jwt_expires_at.to_i,
            iss: default_jwt_issuer[0]
          }
        end

        def default_access
          ["bps:#{version}:general"]
        end

        NewJWT = Struct.new(:key, :new_token, :expires_at)
      end
    end
  end
end
