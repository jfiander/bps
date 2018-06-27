# frozen_string_literal: true

module FloatPlanPDF::BoatInformation
  def boat_information(float_plan)
    draw_text 'Boat Information', size: 16, at: [300, 600]
    draw_text 'Type:', size: 14, at: [300, 580]
    draw_text float_plan.boat_type_display, size: 12, at: [360, 580]
    draw_text 'Name:', size: 14, at: [300, 560]
    draw_text float_plan.boat_name, size: 12, at: [360, 560]
    draw_text 'Length:', size: 14, at: [300, 540]
    draw_text "#{float_plan.length} feet", size: 12, at: [360, 540]
    draw_text 'Make:', size: 14, at: [300, 520]
    draw_text [float_plan.make, float_plan.model, float_plan.year].reject(&:blank?).join(' / '), size: 12, at: [360, 520]
    draw_text 'Color:', size: 14, at: [300, 500]
    draw_text "#{float_plan.hull_color} (hull)", size: 12, at: [360, 500]
    draw_text "#{float_plan.trim_color} (trim)", size: 12, at: [(420 + float_plan.hull_color.length * 4), 500] if float_plan.trim_color.present?
    draw_text 'Registration:', size: 14, at: [300, 480]
    draw_text float_plan.registration_number, size: 12, at: [400, 480]
    draw_text 'Engines:', size: 14, at: [300, 460]
    draw_text float_plan.engines, size: 12, at: [380, 460]
    draw_text 'Fuel cap:', size: 14, at: [300, 440]
    draw_text float_plan.fuel, size: 12, at: [380, 440]
  end
end
