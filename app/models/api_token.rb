# frozen_string_literal: true

require 'bcrypt'

class ApiToken < ApplicationRecord
  belongs_to :user
  has_secure_token

  attr_reader :new_token

  scope :current, -> { where('expires_at > ?', Time.now) }
  scope :expired, -> { where('expires_at <= ?', Time.now) }

  before_create :set_expiration
  before_create :encrypt_token

  def current?
    expires_at > Time.now
  end

  def match?(other)
    BCrypt::Password.new(token) == other
  end

private

  def set_expiration
    self.expires_at = Time.now + 15.minutes
  end

  def encrypt_token
    @new_token = token
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    self.token = BCrypt::Password.create(token, cost: cost)
  end
end
