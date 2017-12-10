class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  has_paper_trail

  def self.find_or_create(attributes)
    query = self.find_by(attributes)
    return self.create!(attributes) if query.blank?
    query
  end

  def self.buckets
    {
      static: BpsS3.new { |b| b.bucket = :static },
      files:  BpsS3.new { |b| b.bucket = :files },
      bilge:  BpsS3.new { |b| b.bucket = :bilge },
      photos: BpsS3.new { |b| b.bucket = :photos }
    }
  end
end
