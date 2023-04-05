# frozen_string_literal: true

class OTWTraining < ApplicationRecord
  extend Ordered

  has_many :otw_training_users, dependent: :destroy
  has_many :users, through: :otw_training_users

  validates :name, uniqueness: true

  validates :boc_level, inclusion: [
    'Inland Navigator',
    'Coastal Navigator',
    'Advanced Coastal Navigator',
    'Offshore Navigator',
    '',
    nil
  ]
end
