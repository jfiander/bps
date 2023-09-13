# frozen_string_literal: true

# Configuration for payable models
module Concerns
  module Payment
    module ModelConfigs
      extend ActiveSupport::Concern

      def purchase_info
        case parent_type
        when 'Registration'
          registration_info
        when 'MemberApplication'
          member_application_info
        when 'User'
          dues_info
        when 'GenericPayment'
          generic_info
        end
      end

      def purchase_subject
        case parent_type
        when 'Registration'
          registration_subject
        when 'MemberApplication'
          'Membership application'
        when 'User'
          'Annual dues'
        when 'GenericPayment'
          parent.description
        end
      end

      def registration?
        parent_type == 'Registration'
      end

      def member_application?
        parent_type == 'MemberApplication'
      end

      def dues_renewal?
        parent_type == 'User'
      end

      def generic?
        parent_type == 'GenericPayment'
      end

    private

      def displayable_registration_types
        %w[course seminar]
      end

      def registration_info
        type = parent.type if parent.type.in?(displayable_registration_types)

        info = registration_base_info(type)
        return info unless parent.additional_registrations.any?

        info.merge(registered: [parent] + parent.additional_registrations)
      end

      def registration_base_info(type)
        {
          name: parent.event.display_title,
          type: type,
          price_comment: parent.event&.location&.price_comment
        }.merge(registration_times).merge(promo_info)
      end

      def registration_subject
        "#{parent.event.display_title} on " \
          "#{parent.event.start_at.strftime(TimeHelper::SHORT_TIME_FORMAT)}"
      end

      def registration_times
        {
          date: parent.event.start_at.strftime(TimeHelper::PUBLIC_DATE_FORMAT),
          time: parent.event.start_at.strftime(TimeHelper::PUBLIC_TIME_FORMAT)
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

      def generic_info
        { name: parent.description }
      end
    end
  end
end
