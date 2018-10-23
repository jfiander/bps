# frozen_string_literal: true

class Role < ApplicationRecord
  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles
  belongs_to :parent, class_name: 'Role', optional: true
  has_many :children, class_name: 'Role', foreign_key: :parent_id, inverse_of: :parent

  before_validation { self.parent ||= Role.find_by(name: 'admin') }

  validate :descends_from_admin?
  validates :name, uniqueness: true

  after_create { User::Permissions.reload_implicit_roles_hash }

  def parents
    parent_role = parent
    parents_array = []

    while parent_role.present?
      parents_array << parent_role
      parent_role = parent_role.parent
    end

    parents_array
  end

private

  def descends_from_admin?
    return true if name == 'admin'
    return true if parents.map(&:name).include? 'admin'

    errors.add(:parent, 'must descend from :admin')
  end
end
