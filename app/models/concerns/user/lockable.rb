# frozen_string_literal: true

module User::Lockable
  extend ActiveSupport::Concern

  def locked?
    locked_at.present?
  end

  def lock
    update(locked_at: Time.now)
  end

  def unlock
    update(locked_at: nil)
  end
end
