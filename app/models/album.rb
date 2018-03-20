class Album < ApplicationRecord
  has_many :photos

  validates :name, uniqueness: true

  def cover
    photos.first
  end
end
