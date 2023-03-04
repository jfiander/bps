# frozen_string_literal: true

module Concerns
  module Event
    module Boolean
      extend ActiveSupport::Concern

      def expired?
        expires_at.present? && expires_at < Time.zone.now
      end

      def archived?
        archived_at.present? && archived_at < Time.zone.now
      end

      def cutoff?
        (cutoff_at.present? && cutoff_at < Time.zone.now) || full?
      end

      def full?
        registration_limit.to_i.positive? && registrations.count >= registration_limit.to_i
      end

      def reminded?
        reminded_at.present?
      end

      def within_a_week?
        time_diff = (start_at - Time.zone.now)
        time_diff < 7.days && time_diff > 0.days
      end

      def length?
        length.present? && length&.strftime('%H%M') != '0000'
      end

      def multiple_sessions?
        sessions.present? && sessions > 1
      end

      def registerable?
        allow_any_registrations? && !cutoff? && (!expired? || start_at > Time.zone.now)
      end

    private

      def allow_any_registrations?
        allow_member_registrations? || allow_public_registrations?
      end
    end
  end
end
