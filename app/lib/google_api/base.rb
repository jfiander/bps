# frozen_string_literal: true

module GoogleAPI
  class Base
    include GoogleAPI::Concerns::Authorization

    def initialize(auth: true)
      self.authorize! if auth
    end

  private

    def service
      raise 'No service class defined.' unless defined?(service_class)

      @service ||= service_class.new
    end

    def call(method, *args)
      ExpRetry.for(exception: Google::Apis::TransmissionError) { service.send(method, *args) }
    end
  end
end
