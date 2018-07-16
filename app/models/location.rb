# frozen_string_literal: true

class Location < ApplicationRecord
  has_attached_file(
    :picture,
    paperclip_defaults(:files).merge(
      path: 'location_images/:id/:style/:filename',
      styles: { large: '1000x1000', medium: '500x500', thumb: '200x200' }
    )
  )

  before_validation { prefix_map_link }

  validates_attachment_content_type :picture, content_type: %r{\Aimage/}
  validates :address, presence: true
  validates :address, uniqueness: true

  validate :valid_map_link?

  def display
    return { id: 0, address: 'TBD' } unless address.present?

    { id: id }.merge(details_hash)
  end

  def self.searchable
    all.map do |l|
      { l.id => l.details_hash }
    end.reduce({}, :merge)
  end

  def details_hash
    {
      name: address.split("\n").first,
      address: address,
      map_link: map_link,
      details: details,
      picture: picture
    }
  end

  private

  def prefix_map_link
    return if map_link.blank? || map_link.match(%r{https?://})

    self.map_link = "http://#{map_link}"
  end

  def valid_map_link?
    return if map_link.blank?

    uri = URI.parse(map_link)
    uri.is_a?(URI::HTTP) && !uri.host.nil?
  rescue URI::InvalidURIError
    errors.add(:map_link, 'is not a valid URL.')
    false
  end
end
