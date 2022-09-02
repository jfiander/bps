# frozen_string_literal: true

module BPS
  class ErrorWithMetadata < StandardError
    attr_reader :metadata

    def initialize(message, **metadata)
      super(message)
      @metadata = metadata
    end

    # def bugsnag_meta_data
    #   {
    #     tab_name: {
    #       field_1: metadata[:field_1],
    #       field_2: metadata[:field_2]
    #     }
    #   }
    # end
  end
end
