# frozen_string_literal: true

module EventTypeHelper
  def event_type_book_cover(event_type)
    bucket = BPS::S3.new(:static)

    if event_type.event_category.in?(%w[advanced_grade elective])
      dir = 'courses'
    elsif event_type.event_category == 'seminar'
      dir = 'seminars'
    end

    key = "book_covers/#{dir}/#{@event_type.title}.jpg"
    image_tag(bucket.link(key)) if dir.present? && bucket.has?(key)
  end
end
