# frozen_string_literal: true

class PromoCode < ApplicationRecord
  has_many :registrations
  has_many :payments
  has_many :event_promo_codes
  has_many :events, through: :event_promo_codes

  scope :expired, -> { where('expires_at < ?', Time.now) }
  scope :current, -> { where('valid_at < ? AND (expires_at > ? OR expires_at IS NULL)', Time.now, Time.now) }
  scope :pending, -> { where('(valid_at > ? OR valid_at IS NULL) AND (expires_at > ? OR expires_at IS NULL)', Time.now, Time.now) }

  validates :code, presence: true

  def pending?
    valid_at.nil? || valid_at > Time.now
  end

  def active?
    valid_at.present? && valid_at < Time.now && (expires_at.nil? || expires_at > Time.now)
  end

  def expired?
    expires_at.present? && expires_at < Time.now
  end

  def usable?
    active? && discount_type.present?
  end

  def activatable?
    (pending? || expired?) && discount_type.present?
  end

  def discount_display
    {
      percent: "#{discount_amount} %", usd: "$ #{discount_amount}",
      member: 'Member Rate', usps: 'USPS Rate'
    }[discount_type&.to_sym] || 'None'
  end

  def activate!
    now = Time.now
    update(valid_at: now)
    update(expires_at: nil) if expired?
  end

  def expire!
    update(expires_at: Time.now)
  end
end
