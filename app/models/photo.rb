class Photo < ApplicationRecord
  belongs_to :album

  has_attached_file :photo_file,
    storage: :s3,
    s3_region: 'us-east-2',
    path: 'photos/:id/:style/:filename',
    s3_permissions: :private,
    s3_credentials: {bucket: self.buckets[:photos].full_bucket, access_key_id: ENV['S3_ACCESS_KEY'], secret_access_key: ENV['S3_SECRET']},
    styles: { medium: '500x500', thumb: '200x200' }

  validates_attachment_content_type :photo_file, content_type: /\Aimage\/.*\z/
  validates :photo_file, presence: true

  acts_as_paranoid
end
