# frozen_string_literal: true

module FloatPlanPDF::BoatInformation
  def boat_information(float_plan)
    draw_text 'Boat Information', size: 16, at: [300, 600]
    labeled_text('Type', float_plan.boat_type_display, x1: 300, x2: 360, y: 580)

    labeled_text('Name', float_plan.boat_name, x1: 300, x2: 360, y: 560)
    labeled_text('Length', float_plan.length, x1: 300, x2: 360, y: 540)
    labeled_text(
      'Make',
      [float_plan.make, float_plan.model, float_plan.year].reject(&:blank?)
                                                          .join(' / '),
      x1: 300, x2: 360, y: 520
    )
    labeled_text('Color', "#{float_plan.hull_color} (hull)", x1: 300, x2: 360, y: 500)
    draw_text "#{float_plan.trim_color} (trim)", size: 12, at: [(420 + float_plan.hull_color.length * 4), 500] if float_plan.trim_color.present?
    labeled_text('Reg num', float_plan.registration_number, x1: 300, x2: 360, y: 480)
    labeled_text('Engines', float_plan.engines, x1: 300, x2: 360, y: 460)
    labeled_text('Fuel cap', float_plan.fuel, x1: 300, x2: 360, y: 440)
  end
end
