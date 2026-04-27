# frozen_string_literal: true

class Event
  module Flyer
    extend ActiveSupport::Concern

    def pick_flyer
      if flyer.present?
        BPS::S3.new(:files).link(flyer&.s3_object&.key)
      elsif course?
        book_cover(:courses)
      elsif seminar?
        book_cover(:seminars)
      end
    end

  private

    def book_cover(type)
      BPS::S3.new(:static).link("book_covers/#{type}/#{cover_file_name}.jpg")
    end

    def cover_file_name
      event_type.title.delete("',")
    end
  end
end
