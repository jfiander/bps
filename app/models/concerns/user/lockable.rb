# frozen_string_literal: true

class User
  module Lockable
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
end
