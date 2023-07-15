# frozen_string_literal: true

class ImportLog < ApplicationRecord
  serialize :proto, BPS::Update::UserDataImport

  def self.latest
    all.order(:created_at).last
  end

  # :nocov:
  def self.archives
    BPS::S3.new(:files).list('user_imports/').map do |f|
      f.key.delete('user_imports/').delete('.proto').to_i
    end.sort
  end

  def self.from_s3(timestamp)
    bin = BPS::S3.new(:files).download("user_imports/#{timestamp}.proto")
    new(proto: bin).proto
  end

  def self.latest_from_s3
    from_s3(archives.last)
  end
  # :nocov:
end
