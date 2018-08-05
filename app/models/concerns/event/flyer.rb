# frozen_string_literal: true

module Concerns::Event::Flyer
  def get_flyer(event_types = nil)
    if use_course_book_cover?(event_types)
      get_book_cover(:courses, event_types)
    elsif use_seminar_book_cover?(event_types)
      get_book_cover(:seminars, event_types)
    elsif flyer.present?
      Event.buckets[:files].link(flyer&.s3_object&.key)
    end
  end

  private

  def get_book_cover(type, event_types = nil)
    filename = cover_file_name(event_types)
    Event.buckets[:static].link("book_covers/#{type}/#{filename}.jpg")
  end

  def cover_file_name(event_types = nil)
    event_types ||= EventType.all
    event_types.select { |e| e.id == event_type_id }.first.title.delete("',")
  end

  def use_course_book_cover?(event_types = nil)
    course?(event_types) && flyer.blank?
  end

  def use_seminar_book_cover?(event_types = nil)
    seminar?(event_types) && flyer.blank?
  end
end
