# frozen_string_literal: true

class Location < ApplicationRecord
  has_attached_file :picture,
    storage: :s3,
    s3_region: 'us-east-2',
    path: 'location_images/:id/:style/:filename',
    s3_permissions: :private,
    s3_credentials: aws_credentials(:files),
    styles: { large: '1000x1000', medium: '500x500', thumb: '200x200' }

  before_validation { prefix_map_link }

  validates_attachment_content_type :picture, content_type: %r{\Aimage/}
  validates :address, presence: true
  validates :address, uniqueness: true

  def display
    return { id: 0, address: 'TBD' } unless address.present?

    {
      id: id,
      name: address.split("\n").first,
      address: address,
      map_link: map_link,
      details: details,
      picture: picture
    }
  end

  def self.searchable
    all.map do |l|
      {
        l.id => {
          name: l.address.split("\n").first,
          address: l.address,
          map_link: l.map_link,
          details: l.details,
          picture: l.picture
        }
      }
    end.reduce({}, :merge)
  end

  private

  def prefix_map_link
    return if map_link.blank? || map_link.match(%r{https?://})

    self.map_link = "http://#{map_link}"
  end
end
