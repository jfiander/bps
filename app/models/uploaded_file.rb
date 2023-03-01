# frozen_string_literal: true

class UploadedFile < ApplicationRecord
  self.abstract_class = true

  ACCEPTABLE_CONTENT_TYPES = %r{\A(image/(jpe?g|png|gif))|(application/pdf)\z}.freeze

  def self.bucket
    :files
  end

  def self.path_pattern
    'uploaded/:class/:id/:filename'
  end

  has_attached_file(:file, paperclip_defaults(bucket).merge(path: path_pattern))

  validates_attachment_content_type(:file, content_type: ACCEPTABLE_CONTENT_TYPES)
  validates(:file, presence: true)

  after_update :invalidate!, if: :will_save_change_to_file_updated_at?
  after_destroy :invalidate!

  def link(permalinks: false)
    return permalink if permalinks

    BPS::S3.new(self.class.bucket).link(file.s3_object.key)
  end

  def invalidate!
    BPS::Invalidation.submit(self.class.bucket, file.s3_object.key)
  end
end
