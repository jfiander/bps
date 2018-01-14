class UserRole < ApplicationRecord
  belongs_to :user
  belongs_to :role

  validates :role, uniqueness: { scope: :user }

  def self.preload
    roles = Role.all.map { |r| {r.id => r.name.to_sym} }.reduce({}, :merge)
    all.group_by { |ur| ur.user_id }.map { |user_id, urs| {user_id => urs.map(&:role_id).map { |r| roles[r] }} }.reduce({}, :merge)
  end
end
