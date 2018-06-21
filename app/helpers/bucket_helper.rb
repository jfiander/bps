# frozen_string_literal: true

# Includable accessor for environmented buckets
module BucketHelper
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

  def floatplans_bucket
    ApplicationRecord.buckets[:floatplans]
  end
end
