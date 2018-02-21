class Album < ApplicationRecord
  has_many :photos

  validates :name, uniqueness: true

  acts_as_paranoid
end
