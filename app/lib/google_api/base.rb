# frozen_string_literal: true

module GoogleAPI
  class Base
    RETRIES ||= [Google::Apis::TransmissionError, Google::Apis::ServerError].freeze

    include GoogleAPI::Concerns::Authorization

    def initialize(auth: true)
      authorize! if auth
    end

  private

    def service
      raise 'No service class defined.' unless defined?(service_class)

      @service ||= service_class.new
    end

    def call(method, *args)
      ExpRetry.for(exception: RETRIES) { service.send(method, *args) }
    end
  end
end
