# frozen_string_literal: true

module BPS
  module PDF
    class FloatPlan
      module BoatInformation
        def boat_information(float_plan)
          draw_text 'Boat Information', size: 16, at: [300, 600]
          labeled_text('Type', float_plan.boat_type_display, x1: 300, x2: 375, y: 580)
          labeled_text('Name', float_plan.boat_name, x1: 300, x2: 375, y: 560)
          h = boat_info_description(float_plan)

          boat_info_numbers(float_plan, h)
          boat_info_engine(float_plan, h)
        end

      private

        def boat_info_description(float_plan)
          labeled_text('Length', "#{float_plan.length} feet", x1: 300, x2: 375, y: 540)
          h = boat_info_make_model(float_plan) * 10
          bounded_text('Color', colors(float_plan), x1: 300, x2: 375, y: 500 - h, split: 15)
        end

        def boat_info_make_model(float_plan)
          bounded_text(
            'Make',
            [
              float_plan.make, float_plan.model, float_plan.year
            ].compact_blank.join(' / '),
            x1: 300, x2: 375, y: 520, split: 20
          )
        end

        def colors(float_plan)
          [
            float_plan.hull_color.present? ? "#{float_plan.hull_color} (hull)\n" : nil,
            float_plan.trim_color.present? ? "#{float_plan.trim_color} (trim)\n" : nil,
            float_plan.deck_color.present? ? "#{float_plan.deck_color} (deck)\n" : nil,
            float_plan.sail_color.present? ? "#{float_plan.sail_color} (sail)\n" : nil
          ].compact.join(' ')
        end

        def boat_info_numbers(float_plan, h)
          reg_num = float_plan.registration_number
          labeled_text('Reg num', reg_num, x1: 300, x2: 375, y: 460 - (h * 10))
          labeled_text('HIN', float_plan.hin, x1: 300, x2: 375, y: 440 - (h * 10))
        end

        def boat_info_engine(float_plan, h)
          h -= 1
          labeled_text('Engines', float_plan.engines, x1: 300, x2: 375, y: 410 - (h * 10))
          labeled_text('Fuel cap', float_plan.fuel, x1: 300, x2: 375, y: 390 - (h * 10))

          @right_y = 390 - (h * 10) - 30
        end
      end
    end
  end
end
