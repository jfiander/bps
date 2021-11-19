# frozen_string_literal: true

module BPS
  module PDF
    class FloatPlan
      module SafetyEquipment
        def safety_equipment(float_plan)
          draw_text 'Safety Equipment', size: 16, at: [300, @right_y]
          safety_row(float_plan, y: safety_row_y, left: 'PFDs', right: 'Flares')
          safety_row(float_plan, y: safety_row_y, left: 'Mirror', right: 'Horn / Whistle')
          safety_row(float_plan, y: safety_row_y, left: 'Smoke', right: 'Flashlight')
          safety_row(float_plan, y: safety_row_y, left: 'EPIRB / PLB', right: 'Raft')
          safety_row(float_plan, y: safety_row_y, left: 'Anchor', right: 'Paddles')
          safety_row(float_plan, y: safety_row_y, left: 'Food', right: 'Water')
        end

      private

        def safety_row_y
          @safety_y ||= @right_y - 10
          @safety_y -= 20
        end

        def safety_row(float_plan, y:, left:, right:)
          safety_left(left, float_plan.send(left.split(' / ').first.downcase), y)
          safety_right(right, float_plan.send(right.split(' / ').first.downcase), y)
        end

        def safety_left(left, equipped, y)
          safety_color(equipped) do
            labeled_text(left, equipped ? 'Yes' : 'No', x1: 300, x2: 390, y: y)
          end
        end

        def safety_right(right, equipped, y)
          safety_color(equipped) do
            labeled_text(right, equipped ? 'Yes' : 'No', x1: 420, x2: 520, y: y)
          end
        end

        def safety_color(equipped)
          configure_colors(equipped ? '009900' : '990000')
          yield
          configure_colors
        end
      end
    end
  end
end
