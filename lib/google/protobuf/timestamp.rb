# frozen_string_literal: true

module Google
  module Protobuf
    class Timestamp
      def to_datetime
        Time.at(seconds).to_datetime
      end
    end
  end
end
