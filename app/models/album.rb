# frozen_string_literal: true

class Album < ApplicationRecord
  has_many :photos

  validates :name, uniqueness: true

  def cover
    cover_id.present? ? photos.select { |p| p.id == cover_id }.first : photos.first
  end
end
