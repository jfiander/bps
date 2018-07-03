# frozen_string_literal: true

# Includable accessor for environmented buckets
module BucketHelper
  ApplicationRecord::BUCKETS.each do |bucket|
    define_method("#{bucket}_bucket") { ApplicationRecord.buckets[bucket] }
  end
end
