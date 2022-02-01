# frozen_string_literal: true

module Api
  module V1
    module JWT
      module Decode
        include Shared

        EXPIRED_TOKEN = 'Your token has expired.'
        INVALID_ISSUER = 'That token has an invalid issuer.'
        INVALID_ACCESS_RESTRICTION = 'Your token does not have access to that action.'

        def decode_jwt(token)
          options = { required_claims: %w[exp iss], algorithm: 'HS512' }
          jwt = ::JWT.decode(token, nil, true, options) do |_headers, payload|
            jwt_issuers[payload['iss']]
          end
          verify_access!(jwt)
        rescue ::JWT::ExpiredSignature
          deny_access!(EXPIRED_TOKEN, :unauthorized)
        rescue ::JWT::InvalidIssuerError
          deny_access!(INVALID_ISSUER, :unauthorized)
        rescue ::JWT::DecodeError => e
          raise e unless e.message == 'No verification key available'

          deny_access!(INVALID_ISSUER, :unauthorized)
        rescue Api::V1::JWT::AccessRestrictionError
          deny_access!(INVALID_ACCESS_RESTRICTION, :unauthorized)
        end

        def verify_access!(jwt)
          puts "\n*** Required: #{['bps', version, controller_name, action_name].inspect}"
          unless format_access(jwt[0]['data']['access']).find { |access| access_match(access) }
            raise Api::V1::JWT::AccessRestrictionError
          end

          jwt
        end

        def access_match(access)
          b, v, c, a = access.split(':')

          return unless b == 'bps'
          return unless v == version
          return unless c.in?([controller_name, '*'])
          return unless a.in?([action_name, '*'])

          access
        end
      end
    end
  end
end
