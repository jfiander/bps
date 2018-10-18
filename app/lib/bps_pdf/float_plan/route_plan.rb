# frozen_string_literal: true

module BpsPdf::FloatPlan::RoutePlan
  def route_plan(float_plan)
    draw_text 'Route Plan', size: 16, at: [25, (380 + @left_vertical_offset)]
    labeled_text('Leave From', float_plan.leave_from, x1: 25, x2: 120, y: (360 + @left_vertical_offset))
    labeled_text('Going To', float_plan.going_to, x1: 25, x2: 120, y: (340 + @left_vertical_offset))
    labeled_text('Leave At', float_plan.leave_at, x1: 25, x2: 120, y: (320 + @left_vertical_offset))
    labeled_text('Return At', float_plan.return_at, x1: 25, x2: 120, y: (300 + @left_vertical_offset))
  end
end
