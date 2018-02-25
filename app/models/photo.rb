class Photo < ApplicationRecord
  belongs_to :album

  has_attached_file :photo_file,
    storage: :s3,
    s3_region: 'us-east-2',
    path: ':id/:style/:filename',
    s3_permissions: :private,
    s3_credentials: aws_credentials(:photos),
    styles: { medium: '500x500', thumb: '200x200' }

  validates_attachment_content_type :photo_file, content_type: %r{\Aimage/}
  validates :photo_file, presence: true

  acts_as_paranoid
end
