# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include Payable

  self.abstract_class = true
  has_paper_trail
  acts_as_paranoid

  # Used by Paperclip
  def self.paperclip_defaults(bucket)
    defaults = {
      storage: :s3, s3_region: 'us-east-2', s3_permissions: :private,
      s3_credentials: { bucket: BPS::S3.new(bucket).full_bucket },
      preserve_files: 'true'
    }

    unless BPS::Application.deployed?
      defaults[:s3_credentials].merge!(
        access_key_id: ENV['AWS_ACCESS_KEY'],
        secret_access_key: ENV['AWS_SECRET']
      )
    end

    defaults
  end

  def versions_path
    Rails.application.routes.url_helpers.admin_show_versions_path(model: self.class.name, id: id)
  end

private

  def sanitize(text)
    ActionController::Base.helpers.sanitize text
  end
end
