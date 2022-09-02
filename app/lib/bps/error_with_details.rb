# frozen_string_literal: true

module BPS
  class ErrorWithDetails
    def self.call(klass, message, **metadata)
      e = klass.new(message, metadata)
      Bugsnag.notify(e) { |b| b.meta_data = e.bugsnag_meta_data }
      puts ''
      e
    end
  end
end
