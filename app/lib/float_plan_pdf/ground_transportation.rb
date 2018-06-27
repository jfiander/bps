# frozen_string_literal: true

module FloatPlanPDF::GroundTransportation
  def ground_transportation(float_plan)
    draw_text 'Ground Transportation', size: 16, at: [25, (200 + @left_vertical_offset)]
    if car_fields(float_plan).any?(&:present?)
      car_details(float_plan)
      trailer_plate(float_plan)
      draw_text 'Parked At:', size: 14, at: [25, (120 + @left_vertical_offset)]
      draw_text float_plan.car_parked_at, size: 12, at: [120, (120 + @left_vertical_offset)]
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
    draw_text 'Car:', size: 14, at: [25, (180 + @left_vertical_offset)]
    draw_text [
      float_plan.car_make,
      float_plan.car_model,
      float_plan.car_year,
      float_plan.car_color
    ].reject(&:blank?).join(' / '), size: 12, at: [120, (180 + @left_vertical_offset)]
    draw_text 'License:', size: 14, at: [25, (160 + @left_vertical_offset)]
    draw_text float_plan.car_license_plate, size: 12, at: [120, (160 + @left_vertical_offset)]
  end

  def trailer_plate(float_plan)
    if float_plan.trailer_license_plate.present?
      draw_text 'Trailer License:', size: 14, at: [25, (140 + @left_vertical_offset)]
      draw_text float_plan.trailer_license_plate, size: 12, at: [120, (140 + @left_vertical_offset)]
    else
      @left_vertical_offset += 20
    end
  end
end
