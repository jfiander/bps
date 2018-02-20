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

    dimensions = Paperclip::Geometry.from_file(image)
    ratio = dimensions.width / dimensions.height
    errors.add(:file, 'must be at least 1000px wide') if dimensions.width < 750
    errors.add(:file, 'aspect ratio must be less than 3.5:1') if ratio > 3.5
    errors.add(:file, 'aspect ratio must be more than 2.75:1') if ratio < 2.75
    true
  end
end
