# frozen_string_literal: true

require 'bcrypt'

class ApiToken < ApplicationRecord
  MINIMUM_TOKEN_LENGTH = 32

  belongs_to :user
  has_secure_token
  has_secure_token :key

  attr_reader :new_token

  scope :current, -> { where('expires_at > ?', Time.zone.now) }
  scope :expired, -> { where('expires_at <= ?', Time.zone.now) }

  before_validation :set_expiration
  before_create :encrypt_token

  validate :validate_expiration

  def self.generate_unique_secure_token(length: self::MINIMUM_TOKEN_LENGTH)
    length = self::MINIMUM_TOKEN_LENGTH if length < self::MINIMUM_TOKEN_LENGTH
    SecureRandom.base58(length)
  end

  def current?
    expires_at > Time.zone.now
  end

  def match?(other)
    BCrypt::Password.new(token) == other
  end

  def expire!
    update!(expires_at: Time.zone.now)
  end

private

  def set_expiration
    self.expires_at = 15.minutes.from_now unless persisted?
  end

  def encrypt_token
    @new_token = token
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    self.token = BCrypt::Password.create(token, cost: cost)
  end

  def validate_expiration
    errors.add(:expires_at, 'must not be nil') if expires_at.nil?
  end
end
