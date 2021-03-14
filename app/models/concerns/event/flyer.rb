# frozen_string_literal: true

module Concerns
  module Event
    module Flyer
      extend ActiveSupport::Concern

      def pick_flyer
        if use_course_book_cover?
          book_cover(:courses)
        elsif use_seminar_book_cover?
          book_cover(:seminars)
        elsif flyer.present?
          BpsS3.new(:files).link(flyer&.s3_object&.key)
        end
      end

    private

      def book_cover(type)
        BpsS3.new(:static).link("book_covers/#{type}/#{cover_file_name}.jpg")
      end

      def cover_file_name
        event_type.title.delete("',")
      end

      def use_course_book_cover?
        course? && flyer.blank?
      end

      def use_seminar_book_cover?
        seminar? && flyer.blank?
      end
    end
  end
end
