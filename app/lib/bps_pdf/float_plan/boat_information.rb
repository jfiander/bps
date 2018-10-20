# frozen_string_literal: true

module BpsPdf::FloatPlan::BoatInformation
  def boat_information(float_plan)
    draw_text 'Boat Information', size: 16, at: [300, 600]
    labeled_text('Type', float_plan.boat_type_display, x1: 300, x2: 375, y: 580)
    labeled_text('Name', float_plan.boat_name, x1: 300, x2: 375, y: 560)
    boat_info_description(float_plan)
    boat_info_engine(float_plan)
  end

private

  def boat_info_description(float_plan)
    labeled_text('Length', "#{float_plan.length} feet", x1: 300, x2: 375, y: 540)
    boat_info_make_model(float_plan)
    labeled_text('Color', "#{float_plan.hull_color} (hull)", x1: 300, x2: 375, y: 500)
    if float_plan.trim_color.present?
      draw_text(
        "#{float_plan.trim_color} (trim)", size: 12,
        at: [(420 + float_plan.hull_color.length * 4), 500]
      )
    end
    labeled_text('Reg num', float_plan.registration_number, x1: 300, x2: 375, y: 480)
  end

  def boat_info_make_model(float_plan)
    labeled_text(
      'Make',
      [
        float_plan.make, float_plan.model, float_plan.year
      ].reject(&:blank?).join(' / '),
      x1: 300, x2: 375, y: 520
    )
  end

  def boat_info_engine(float_plan)
    labeled_text('Engines', float_plan.engines, x1: 300, x2: 375, y: 460)
    labeled_text('Fuel cap', float_plan.fuel, x1: 300, x2: 375, y: 440)
  end
end
