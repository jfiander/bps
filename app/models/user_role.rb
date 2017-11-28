class UserRole < ApplicationRecord
  belongs_to :user
  belongs_to :role

  validates :role, uniqueness: { scope: :user }
end
