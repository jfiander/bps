class User < ApplicationRecord
  devise :invitable, :registerable, :database_authenticatable, :recoverable, :trackable, :validatable, :timeoutable, :lockable
  has_many :user_roles
  has_many :roles, through: :user_roles
end
