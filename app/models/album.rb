class Album < ApplicationRecord
  has_many :photos

  acts_as_paranoid
end
