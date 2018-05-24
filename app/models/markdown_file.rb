# frozen_string_literal: true

class MarkdownFile < ApplicationRecord
  has_attached_file :file,
    default_url: nil,
    storage: :s3,
    s3_region: 'us-east-2',
    path: 'uploaded_files/:id/:filename',
    s3_permissions: :private,
    s3_credentials: aws_credentials(:files)

  validates_attachment_content_type :file, content_type: %r{\A(image/(jpe?g|png|gif))|(application/pdf)\z}
  validates :file, presence: true
end
