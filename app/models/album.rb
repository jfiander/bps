class Album < ApplicationRecord
  has_many :photos

  validates :name, uniqueness: true
end
