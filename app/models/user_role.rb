# frozen_string_literal: true

class UserRole < ApplicationRecord
  belongs_to :user
  belongs_to :role

  validates :role, uniqueness: { scope: :user }

  def self.preload
    roles = Role.all.each_with_object({}) { |r, h| h[r.id] = r.name.to_sym }
    all.each_with_object({}) do |user_role, hash|
      hash[user_role.user_id] ||= []
      hash[user_role.user_id] << roles[user_role.role_id]
    end
  end
end
