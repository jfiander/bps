# frozen_string_literal: true

require 'bcrypt'

class PersistentApiToken < ApiToken
  MINIMUM_TOKEN_LENGTH = 64

  scope :current, -> { where('expires_at IS NULL', Time.now) }

  def current?
    expires_at.nil?
  end

private

  def set_expiration
    self.expires_at = nil unless persisted?
  end

  def validate_expiration
    true # Ignore parent validation -- nil is acceptable here
  end
end
