# frozen_string_literal: true

# Configuration for payable models
module Concerns
  module Payment
    module ModelConfigs
      extend ActiveSupport::Concern

      def purchase_info
        case parent_type
        when 'Registration'
          type = parent.type
          type = nil unless type.in?(displayable_registration_types)
          registration_info(type)
        when 'MemberApplication'
          member_application_info
        when 'User'
          dues_info
        end
      end

      def purchase_subject
        case parent_type
        when 'Registration'
          "#{parent.event.display_title} on " \
          "#{parent.event.start_at.strftime(ApplicationController::SHORT_TIME_FORMAT)}"
        when 'MemberApplication'
          'Membership application'
        when 'User'
          'Annual dues'
        end
      end

    private

      def displayable_registration_types
        %w[course seminar]
      end

      def registration_info(type = nil)
        {
          name: parent.event.display_title,
          registered: parent.user_registrations,
          type: type,
          price_comment: parent.event&.location&.price_comment
        }.merge(registration_times).merge(promo_info)
      end

      def registration_times
        {
          date: parent.event.start_at.strftime(ApplicationController::PUBLIC_DATE_FORMAT),
          time: parent.event.start_at.strftime(ApplicationController::PUBLIC_TIME_FORMAT)
        }
      end

      def promo_info
        {
          promo_code: parent.payment&.promo_code&.code,
          codes_available: parent.event&.promo_codes&.any?
        }
      end

      def member_application_info
        { name: 'Membership application', people: parent.member_applicants.count }
      end

      def dues_info
        { name: 'Annual dues', people: parent.children.count }
      end
    end
  end
end
