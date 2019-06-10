# frozen_string_literal: true

module BpsPdf
  class FloatPlan
    module Comments
      def comments(float_plan)
        draw_text 'Comments:', size: 14, at: [25, (60 + @left_vertical_offset)]
        bounding_box([25, (40 + @left_vertical_offset)], width: 500, height: comments_height) do
          text float_plan.comments, size: 12
        end
      end

    private

      def comments_height
        (50 + @left_vertical_offset)
      end
    end
  end
end
