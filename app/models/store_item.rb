class StoreItem < ApplicationRecord
  serialize :options

  def self.no_image
    ActionController::Base.helpers.image_path(StoreItem.buckets[:static].link(key: "no_image.png"))
  end

  has_attached_file :image,
    default_url: StoreItem.no_image,
    storage: :s3,
    s3_region: "us-east-2",
    path: "store_items/:id/:filename",
    s3_permissions: :private,
    s3_credentials: {bucket: self.buckets[:files].bucket, access_key_id: ENV["S3_ACCESS_KEY"], secret_access_key: ENV["S3_SECRET"]}

  validates_attachment_content_type :image, content_type: /\Aimage\/(jpe?g|png|gif)\Z/
  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_validation do
    self.stock ||= 0
    self.price ||= 0.00
  end

  def options_hash
    prepared_options = "{" + options.delete('"').split(/\r?\n/).map { |o| o.gsub(/(.*?):\s?(.*?)/, '"\1": "\2') + '"' }.join(", ") + "}"
    JSON.parse(prepared_options)
  end

  def get_image
    if image.present? && StoreItem.buckets[:files].object(key: image.s3_object.key).exists?
      StoreItem.buckets[:files].link(key: image.s3_object.key)
    else
      StoreItem.no_image
    end
  end
end
