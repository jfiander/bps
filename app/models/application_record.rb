# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  has_paper_trail
  acts_as_paranoid

  def self.buckets
    {
      static:     BpsS3.new(:static),
      files:      BpsS3.new(:files),
      bilge:      BpsS3.new(:bilge),
      photos:     BpsS3.new(:photos),
      floatplans: BpsS3.new(:floatplans)
    }
  end

  # Used by Paperclip
  def self.paperclip_defaults(bucket)
    {
      storage: :s3, s3_region: 'us-east-2', s3_permissions: :private,
      s3_credentials: {
        bucket: buckets[bucket].full_bucket,
        access_key_id: ENV['S3_ACCESS_KEY'],
        secret_access_key: ENV['S3_SECRET']
      }
    }
  end

  def versions_path
    Rails.application.routes.url_helpers.show_versions_path(
      model: self.class.name, id: id
    )
  end
end
