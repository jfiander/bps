# frozen_string_literal: true

module Concerns
  module Event
    module Cost
      extend ActiveSupport::Concern

      def formatted_cost
        # html_safe: User content is restricted to integers
        return if cost.blank?

        u = ", <b>USPS members:</b>&nbsp;$#{usps_cost}" if usps_cost.present?
        return "<b>Cost:</b>&nbsp;$#{cost}#{u}".html_safe if member_cost.blank?

        "<b>Members:</b>&nbsp;$#{member_cost}#{u}, <b>Non-members:</b>&nbsp;$#{cost}".html_safe
      end

      def get_cost(member = false)
        return member_cost if member && member_cost.present?
        return cost if cost.present?

        0
      end

      def costs
        { general: cost, usps: usps_cost, member: member_cost }
      end

    private

      def validate_costs
        return clear_costs if cost.blank?

        if member_cost.present?
          swap_member_cost if member_cost > cost
          clear_member_cost if member_cost == cost
        end
        clear_usps_cost if usps_cost.present? && invalid_usps_cost?
      end

      def clear_costs
        clear_member_cost
        clear_usps_cost
      end

      def clear_member_cost
        self.member_cost = nil
      end

      def clear_usps_cost
        self.usps_cost = nil
      end

      def swap_member_cost
        old_cost = cost
        self.cost = member_cost
        self.member_cost = old_cost
      end

      def invalid_member_cost?
        member_cost >= cost
      end

      def invalid_usps_cost?
        usps_cost >= cost || (member_cost.present? && usps_cost <= member_cost)
      end
    end
  end
end
