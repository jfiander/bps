# frozen_string_literal: true

module BPS
  module PDF
    class FloatPlan
      module GroundTransportation
        def ground_transportation(float_plan)
          draw_text 'Ground Transportation', size: 16, at: [25, (200 + @left_vertical_offset)]
          if car_fields(float_plan).any?(&:present?)
            car_details(float_plan)
            trailer_plate(float_plan)
            labeled_text(
              'Parked At', float_plan.car_parked_at,
              x1: 25, x2: 120, y: (120 + @left_vertical_offset)
            )
          else
            draw_text 'n/a', size: 14, at: [25, (180 + @left_vertical_offset)]
          end
        end

      private

        def car_fields(float_plan)
          [
            float_plan.car_make, float_plan.car_model, float_plan.car_license_plate,
            float_plan.trailer_license_plate, float_plan.car_parked_at
          ]
        end

        def car_details(float_plan)
          car_make_and_model(float_plan)

          labeled_text(
            'License', float_plan.car_license_plate,
            x1: 25, x2: 120, y: (160 + @left_vertical_offset)
          )
        end

        def car_make_and_model(float_plan)
          labeled_text(
            'Car',
            [
              float_plan.car_make, float_plan.car_model,
              float_plan.car_year, float_plan.car_color
            ].compact_blank.join(' / '),
            x1: 25, x2: 120, y: (180 + @left_vertical_offset)
          )
        end

        def trailer_plate(float_plan)
          if float_plan.trailer_license_plate.present?
            labeled_text(
              'Trailer License', float_plan.trailer_license_plate,
              x1: 25, x2: 120, y: (140 + @left_vertical_offset)
            )
          else
            @left_vertical_offset += 20
          end
        end
      end
    end
  end
end
