# frozen_string_literal: true

module BpsPdf
  class FloatPlan
    module Comments
      def comments(float_plan)
        width = @safety_y < 240 && float_plan.onboard.count <= 2 ? 250 : 500
        draw_text 'Comments:', size: 14, at: [25, (80 + @left_vertical_offset)]
        bounding_box([25, (60 + @left_vertical_offset)], width: width, height: comments_height) do
          text float_plan.comments, size: 12
        end
      end

    private

      def comments_height
        (60 + @left_vertical_offset)
      end
    end
  end
end
