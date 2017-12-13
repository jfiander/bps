class Registration < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :event

  # validates :event, uniqueness: {scope: :user}

  scope :current,  -> { all.find_all { |r| r.event.expires_at.future? } }
  scope :expired,  -> { all.find_all { |r| r.event.expires_at.past? } }
  scope :for_user, ->(user_id) { where(user_id: user_id) }
end
