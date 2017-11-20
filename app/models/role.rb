class Role < ApplicationRecord
  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles
  belongs_to :parent, class_name: "Role", optional: true

  def parents
    parent = self.parent
    parents_array = []
    while parent.present?
      parents_array << parent
      parent = parent.parent
    end
    parents_array
  end

  def children
    child_roles  = Role.where(parent_id: self.id).to_a
    child_roles << child_roles.map(&:children) if child_roles.present?
    child_roles.flatten
  end
end
