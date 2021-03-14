# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include Payable

  self.abstract_class = true
  has_paper_trail
  acts_as_paranoid

  # Used by Paperclip
  def self.paperclip_defaults(bucket)
    {
      storage: :s3, s3_region: 'us-east-2', s3_permissions: :private,
      s3_credentials: {
        bucket: BpsS3.new(bucket).full_bucket,
        access_key_id: ENV['S3_ACCESS_KEY'],
        secret_access_key: ENV['S3_SECRET']
      }
    }
  end

  def self.ordered
    path = "#{Rails.root}/app/models/concerns/#{name.underscore}/order.sql"
    return unless File.exist?(path)

    order(Arel.sql(File.read(path)))
  end

  def versions_path
    Rails.application.routes.url_helpers.admin_show_versions_path(
      model: self.class.name, id: id
    )
  end

private

  def sanitize(text)
    ActionController::Base.helpers.sanitize text
  end

  def email_or_user_present
    return if user.present? || email.present?

    errors.add(:base, 'Must have a user or email')
  end
end
