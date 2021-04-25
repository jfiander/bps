# frozen_string_literal: true

module Concerns
  module Event
    module Flyer
      extend ActiveSupport::Concern

      def pick_flyer
        if flyer.present?
          BpsS3.new(:files).link(flyer&.s3_object&.key)
        elsif course?
          book_cover(:courses)
        elsif seminar?
          book_cover(:seminars)
        end
      end

    private

      def book_cover(type)
        BpsS3.new(:static).link("book_covers/#{type}/#{cover_file_name}.jpg")
      end

      def cover_file_name
        event_type.title.delete("',")
      end
    end
  end
end
