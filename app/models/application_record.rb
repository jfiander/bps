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
      s3_credentials: { bucket: BPS::S3.new(bucket).full_bucket }
    }

    unless Rails.env.deployed?
      defaults[:s3_credentials].merge!(
        access_key_id: ENV['S3_ACCESS_KEY'],
        secret_access_key: ENV['S3_SECRET']
      )
    end

    defaults
  end

  def self.order_sql_path
    "#{Rails.root}/app/models/concerns/#{name.underscore}/order.sql"
  end

  def self.order_sql
    File.read(order_sql_path) if File.exist?(order_sql_path)
  end

  def self.ordered
    order(Arel.sql(order_sql)) if File.exist?(order_sql_path)
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
