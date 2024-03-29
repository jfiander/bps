# frozen_string_literal: true

class User
  module Dues
    extend ActiveSupport::Concern

    def dues
      if parent.present?
        { user_id: parent_id }
      elsif children.blank?
        93
      else
        139 + children.count
      end
    end

    def dues_due?
      return false if parent_id.present?
      return true if dues_last_paid_at.blank?

      dues_last_paid_at < 11.months.ago
    end

    def dues_paid!
      update(dues_last_paid_at: Time.zone.now)
    end
  end
end
