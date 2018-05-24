class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  has_paper_trail
  acts_as_paranoid

  def self.buckets
    {
      static: BpsS3.new(:static),
      files:  BpsS3.new(:files),
      bilge:  BpsS3.new(:bilge),
      photos: BpsS3.new(:photos)
    }
  end

  # Used by Paperclip
  def self.aws_credentials(bucket)
    {
      bucket: buckets[bucket].full_bucket,
      access_key_id: ENV['S3_ACCESS_KEY'],
      secret_access_key: ENV['S3_SECRET']
    }
  end
end
