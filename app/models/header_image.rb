class HeaderImage < ApplicationRecord
  has_attached_file :file,
    default_url: nil,
    storage: :s3,
    s3_region: 'us-east-2',
    path: 'header_images/:id/:style/:filename',
    s3_permissions: :private,
    s3_credentials: aws_credentials(:files),
    styles: { desktop: '1500x1500', medium: '500x500', thumb: '200x200' },
    convert_options: { thumb: '-quality 75 -strip' }

  validates_attachment_content_type :file, content_type: %r{\A(image/(jpe?g|png|gif))\Z}
  validates :file, presence: true
  validate :correct_image_dimensions

  acts_as_paranoid

  def self.random
    all&.map(&:file)&.sample
  end

  private

  def correct_image_dimensions
    image = file.queued_for_write[:original]
    return nil if image.nil?

    dimensions, ratio = size_info(image)
    add_errors(dimensions, ratio)
  end

  def size_info(image = file)
    dimensions = Paperclip::Geometry.from_file(image)
    ratio = dimensions.width / dimensions.height

    [dimensions, ratio]
  end

  def add_errors(dimensions, ratio)
    errors.add(:file, too_small) if dimensions.width < 750
    errors.add(:file, too_narrow) if ratio > 3.5
    errors.add(:file, too_wide) if ratio < 2.75
  end

  def too_small
    'must be at least 1000px wide'
  end

  def too_narrow
    'aspect ratio > 3.5:1 (make it wider)'
  end

  def too_wide
    'aspect ratio < 2.75:1 (make it narrower)'
  end
end
