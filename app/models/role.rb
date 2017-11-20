class Role < ApplicationRecord
  has_many :user_roles
  has_many :users, through: :user_roles
  belongs_to :parent, class_name: "Role", optional: true
end
