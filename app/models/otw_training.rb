class OTWTraining < ApplicationRecord
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

  def self.ordered
    order Arel.sql(
      <<~SQL
        CASE
          WHEN boc_level = 'Inland Navigator'           THEN '1' || name
          WHEN boc_level = 'Coastal Navigator'          THEN '2' || name
          WHEN boc_level = 'Advanced Coastal Navigator' THEN '3' || name
          WHEN boc_level = 'Offshore Navigator'         THEN '4' || name
        END
      SQL
    )
  end
end
