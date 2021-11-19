# frozen_string_literal: true

module BPS
  module PDF
    class FloatPlan
      module AlertPlan
        def alert_plan(float_plan)
          configure_colors('CC0000')
          fill_color 'CC0000'
          labeled_text(
            'Alert At', float_plan.alert_at, x1: 25, x2: 120, y: (270 + @left_vertical_offset)
          )
          labeled_text(
            'Alert', float_plan.alert_name, x1: 25, x2: 120, y: (250 + @left_vertical_offset)
          )
          alert_phone(float_plan)
          configure_colors
        end

      private

        def alert_phone(float_plan)
          if float_plan.alert_phone.present?
            labeled_text(
              'Phone', float_plan.alert_phone, x1: 25, x2: 120, y: (230 + @left_vertical_offset)
            )
          else
            @left_vertical_offset += 20
          end
        end
      end
    end
  end
end
