class User < ApplicationRecord
  devise :invitable, :registerable, :database_authenticatable, :recoverable, :trackable, :validatable, :timeoutable, :lockable
  has_many :user_roles
  has_many :roles, through: :user_roles

  validates_inclusion_of :grade, in: %w( S P AP JN N SN ), message: "must be one of [S, P, AP, JN, N, SN]"
end
