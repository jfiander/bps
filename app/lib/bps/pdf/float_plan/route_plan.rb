# frozen_string_literal: true

module BPS
  module PDF
    class FloatPlan
      module RoutePlan
        def route_plan(float_plan)
          draw_text 'Route Plan', size: 16, at: [25, (380 + @left_vertical_offset)]
          route_plan_details(float_plan)
        end

      private

        def route_plan_details(float_plan)
          h = 360 - 10 - (route_plan_text(float_plan, :leave_from, 360) * 10)
          h = h - 10 - (route_plan_text(float_plan, :going_to, h) * 10)
          h = h - 10 - (route_plan_text(float_plan, :leave_at, h) * 10)
          route_plan_text(float_plan, :return_at, h)
        end

        def route_plan_text(float_plan, key, y_pos)
          bounded_text(
            key.to_s.titleize, float_plan.send(key),
            x1: 25, x2: 120, y: (y_pos + @left_vertical_offset)
          )
        end
      end
    end
  end
end
