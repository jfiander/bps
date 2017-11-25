class Registration < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :event

  validates :event, uniqueness: {scope: :user}
end
