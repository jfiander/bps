# frozen_string_literal: true

class Role < ApplicationRecord
  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles
  belongs_to :parent, class_name: 'Role', optional: true

  before_validation { self.parent ||= Role.find_by(name: 'admin') }

  validate :descends_from_admin?
  validates :name, uniqueness: true

  def parents
    parent_role = parent
    parents_array = []
    while parent_role.present?
      parents_array << parent_role
      parent_role = parent_role.parent
    end
    parents_array
  end

  def children
    child_roles = Role.all.to_a.find_all { |r| r.parent_id == id }.to_a
    child_roles << child_roles&.map(&:children)
    child_roles.flatten
  end

  private

  def descends_from_admin?
    return true if name == 'admin'
    return true if parents.map(&:name).include? 'admin'
    false
  end
end
