class MarkdownFile < ApplicationRecord
  has_attached_file :file,
    default_url: nil,
    storage: :s3,
    s3_region: "us-east-2",
    path: "uploaded_files/:id/:filename",
    s3_permissions: :private,
    s3_credentials: {bucket: self.buckets[:files].full_bucket, access_key_id: ENV["S3_ACCESS_KEY"], secret_access_key: ENV["S3_SECRET"]}

  validates_attachment_content_type :file, content_type: /\A(image\/(jpe?g|png|gif))|(application\/pdf)\Z/
  validates :file, presence: true

  acts_as_paranoid
end
