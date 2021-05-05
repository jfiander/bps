# frozen_string_literal: true

class ApiToken < ApplicationRecord
  belongs_to :user
  has_secure_token

  scope :current, -> { where('expires_at > ?', Time.now) }
  scope :expired, -> { where('expires_at <= ?', Time.now) }

  before_create :set_expiration

  def current?
    expires_at > Time.now
  end

private

  def set_expiration
    self.expires_at = Time.now + 15.minutes
  end
end
