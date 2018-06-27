# frozen_string_literal: true

module FloatPlanPDF::Comments
  def comments(float_plan)
    draw_text 'Comments:', size: 14, at: [25, (60 + @left_vertical_offset)]
    bounding_box([25, (40 + @left_vertical_offset)], width: 500, height: (50 + @left_vertical_offset)) do
      text float_plan.comments, size: 12
    end
  end
end
