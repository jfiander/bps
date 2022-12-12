# frozen_string_literal: true

class Album < ApplicationRecord
  has_many :photos

  validates :name, uniqueness: true

  def cover
    return photos.first unless cover_id.present?

    photos.find { |p| p.id == cover_id } || photos.first
  end
end
