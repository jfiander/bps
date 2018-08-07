class OTWTraining < ApplicationRecord
  has_many :otw_training_users, dependent: :destroy
  has_many :users, through: :otw_training_users

  validates :name, uniqueness: true
end
