# frozen_string_literal: true

module Concerns
  module Event
    module Actions
      extend ActiveSupport::Concern

      def register_user(user)
        Registration.create(user: user, event: self)
      end

      def assign_instructor(user)
        EventInstructor.create(event: self, user: user)
      end

      def remind!
        return if reminded?

        registrations.each { |reg| RegistrationMailer.remind(reg).deliver }
        BpsSMS.broadcast(topic_arn, reminder_message(event_type))

        update(reminded_at: Time.now)
      end

      def expire!
        update(expires_at: Time.now)
      end

      def archive!
        update(archived_at: Time.now)
      end

      def attach_promo_code(code, **args)
        promo_code = PromoCode.find_or_create_by(code: code, **args)

        unless (epc = EventPromoCode.find_by(event: self, promo_code: promo_code))
          epc = EventPromoCode.create(event: self, promo_code: promo_code)
        end

        epc
      end

    private

      def reminder_message(event_type)
        <<~MSG
          Quick reminder that you are registered for this upcoming #{event_type.event_category}.

          ABC Birmingham
          abcBirmingham.org
        MSG
      end
    end
  end
end
