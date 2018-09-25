# frozen_string_literal: true

module Concerns::Event::Boolean
  def expired?
    expires_at.present? && expires_at < Time.now
  end

  def cutoff?
    (cutoff_at.present? && cutoff_at < Time.now) || full?
  end

  def full?
    registration_limit.to_i.positive? &&
      registrations.count >= registration_limit.to_i
  end

  def reminded?
    reminded_at.present?
  end

  def within_a_week?
    time_diff = (start_at - Time.now)
    time_diff < 7.days && time_diff > 0.days
  end

  def length?
    length.present? && length&.strftime('%-kh %Mm') != '0h 00m'
  end

  def multiple_sessions?
    sessions.present? && sessions > 1
  end

  def registerable?
    return false if expired? || cutoff?
    return false unless allow_any_registrations?
    true
  end

  private

  def allow_any_registrations?
    allow_member_registrations? || allow_public_registrations?
  end
end
