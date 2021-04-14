# frozen_string_literal: true

module BpsPdf
  class Receipt
    module TransactionInfo
      # This module defines no public methods.
      def _; end

    private

      def transaction_info(payment)
        transaction_details(payment)
        purchase_subject(payment)
      end

      def transaction_details(payment)
        bounding_box([300, 575], width: 250, height: 90) do
          text 'Transaction Info', size: 18, style: :bold, align: :center
          move_down(10)
          text "<b>Transaction ID:</b> #{payment.transaction_id}", size: 14, inline_format: true
          move_down(5)
          date = payment.updated_at.strftime(TimeHelper::MEDIUM_TIME_FORMAT)
          text "<b>Date:</b> #{date}", size: 14, inline_format: true
        end
      end

      def purchase_subject(payment)
        bounding_box([0, 460], width: 550, height: people_height(payment)) do
          text 'Payment Details', size: 18, style: :bold, align: :center
          move_down(10)
          text "<b>#{payment.purchase_subject}</b>", size: 14, align: :center, inline_format: true
          move_down(5)
          model_specific_details(payment)
        end
      end

      def model_specific_details(payment)
        people_details(payment) unless payment.parent.class.name == 'Registration'
      end

      def people(payment)
        return payment.parent&.member_applicants if payment.parent.respond_to?(:member_applicants)
        return payment.parent&.children if payment.parent.respond_to?(:children)

        []
      end

      def people_height(payment)
        150 + (people(payment).count - 4) * 20
      end

      def people_details(payment)
        people(payment).each do |person|
          text "#{person.first_name} #{person.last_name}", size: 14, align: :center
        end
      end
    end
  end
end
