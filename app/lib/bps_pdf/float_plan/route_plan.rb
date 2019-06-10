# frozen_string_literal: true

module BpsPdf
  class FloatPlan
    module RoutePlan
      def route_plan(float_plan)
        draw_text 'Route Plan', size: 16, at: [25, (380 + @left_vertical_offset)]
        route_plan_text(float_plan, :leave_from, 360)
        route_plan_text(float_plan, :going_to, 340)
        route_plan_text(float_plan, :leave_at, 320)
        route_plan_text(float_plan, :return_at, 300)
      end

    private

      def route_plan_text(float_plan, key, y_pos)
        labeled_text(
          key.to_s.titleize, float_plan.send(key),
          x1: 25, x2: 120, y: (y_pos + @left_vertical_offset)
        )
      end
    end
  end
end
