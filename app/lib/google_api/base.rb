# frozen_string_literal: true

module GoogleAPI
  class Base
    include GoogleAPI::Concerns::Authorization

    def initialize(auth: false)
      self.authorize! if auth
    end

  private

    def service
      raise 'No service class defined.' unless defined?(service_class)

      @service ||= service_class.new
    end
  end
end
