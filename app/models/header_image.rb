# frozen_string_literal: true

class HeaderImage < ApplicationRecord
  has_attached_file(
    :file,
    paperclip_defaults(:files).merge(
      path: 'header_images/:id/:style/:filename',
      styles: { desktop: '1500x1500', medium: '500x500', thumb: '200x200' },
      convert_options: {
        desktop: '-quality 60 -strip',
        medium: '-quality 50 -strip',
        thumb: '-quality 40 -strip'
      }
    )
  )

  validates_attachment_content_type(
    :file, content_type: %r{\A(image/(jpe?g|png|gif))\z}
  )
  validates :file, presence: true, if: :no_errors_yet?
  validate :correct_image_dimensions, if: :no_errors_yet?

private

  def correct_image_dimensions
    image = file.queued_for_write[:original]
    return if image.nil?

    dim = Paperclip::Geometry.from_file(file.queued_for_write[:original].path)
    ratio = dim.width / dim.height
    add_errors(dim, ratio)
  end

  def add_errors(dimensions, ratio)
    errors.add(:file, too_small) if dimensions.width < 750
    errors.add(:file, too_wide) if ratio > 3.5
    errors.add(:file, too_narrow) if ratio < 2.75
  end

  def too_small
    'must be at least 1000px wide'
  end

  def too_wide
    'aspect ratio > 3.5:1 (make it narrower)'
  end

  def too_narrow
    'aspect ratio < 2.75:1 (make it wider)'
  end

  def no_errors_yet?
    errors.blank?
  end
end
