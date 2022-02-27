# frozen_string_literal: true

module AutomaticUpdate
  class UpdateError < StandardError
    attr_reader :metadata

    def initialize(message, **metadata)
      super(message)
      @metadata = metadata
    end
  end

  class BugsnagError
    def self.call(klass, message, **metadata)
      e = klass.new(message, metadata)
      Bugsnag.notify(e) { |b| b.meta_data = e.bugsnag_meta_data }
      puts ''
      e
    end
  end
end
