# frozen_string_literal: true

module FloatPlanPDF::PrimaryContact
  def primary_contact(float_plan)
    draw_text 'Primary Contact', size: 16, at: [25, 600]
    draw_text 'Name:', size: 14, at: [25, 580]
    draw_text float_plan.name, size: 12, at: [85, 580]
    draw_text 'Phone:', size: 14, at: [25, 560]
    draw_text float_plan.phone, size: 12, at: [85, 560]
  end
end
