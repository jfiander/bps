# Includable accessor for environmented buckets
module BucketHelpers
  def static_bucket
    ApplicationRecord.buckets[:static]
  end

  def files_bucket
    ApplicationRecord.buckets[:files]
  end

  def bilge_bucket
    ApplicationRecord.buckets[:bilge]
  end

  def photos_bucket
    ApplicationRecord.buckets[:photos]
  end
end
