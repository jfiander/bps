# frozen_string_literal: true

class Roster::PastCommander < ApplicationRecord
  belongs_to :user, optional: true

  validate :user_or_name
  validates :year, presence: true

  def display_name
    return name unless user.present?

    user.simple_name
  end

  def user_or_name
    return true if user.present? || name.present?

    errors.add(:base, 'Must have a user or name')
  end
end
