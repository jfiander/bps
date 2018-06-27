# frozen_string_literal: true

module FloatPlanPDF::RoutePlan
  def route_plan(float_plan)
    draw_text 'Route Plan', size: 16, at: [25, (380 + @left_vertical_offset)]
    locations(float_plan)
    dates(float_plan)
  end

  private

  def locations(float_plan)
    draw_text 'Leave From:', size: 14, at: [25, (360 + @left_vertical_offset)]
    draw_text float_plan.leave_from, size: 12, at: [120, (360 + @left_vertical_offset)]
    draw_text 'Going To:', size: 14, at: [25, (340 + @left_vertical_offset)]
    draw_text float_plan.going_to, size: 12, at: [120, (340 + @left_vertical_offset)]
  end

  def dates(float_plan)
    draw_text 'Leave At:', size: 14, at: [25, (320 + @left_vertical_offset)]
    draw_text float_plan.leave_at, size: 12, at: [120, (320 + @left_vertical_offset)]
    draw_text 'Return At:', size: 14, at: [25, (300 + @left_vertical_offset)]
    draw_text float_plan.return_at, size: 12, at: [120, (300 + @left_vertical_offset)]
  end
end
