# frozen_string_literal: true

module FloatPlanPDF::AlertPlan
  def alert_plan(float_plan)
    configure_colors('CC0000')
    fill_color 'CC0000'
    draw_text 'Alert At:', size: 14, at: [25, (280 + @left_vertical_offset)]
    draw_text float_plan.alert_at, size: 12, at: [120, (280 + @left_vertical_offset)]
    draw_text 'Alert:', size: 14, at: [25, (260 + @left_vertical_offset)]
    draw_text float_plan.alert_name, size: 12, at: [120, (260 + @left_vertical_offset)]
    alert_phone(float_plan)
    configure_colors
  end

  private

  def alert_phone(float_plan)
    if float_plan.alert_phone.present?
      draw_text 'Phone:', size: 14, at: [25, (240 + @left_vertical_offset)]
      draw_text float_plan.alert_phone, size: 12, at: [120, (240 + @left_vertical_offset)]
    else
      @left_vertical_offset += 20
    end
  end
end
