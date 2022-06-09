# frozen_string_literal: true

class GLYCMember < ApplicationRecord
  validates :email, presence: true, uniqueness: true
end
