# frozen_string_literal: true

module FloatPlanPDF::SafetyEquipment
  def safety_equipment(float_plan)
    draw_text 'Safety Equipment', size: 16, at: [300, 400]
    safety_row_1(float_plan)
    safety_row_2(float_plan)
    safety_row_3(float_plan)
    safety_row_4(float_plan)
    safety_row_5(float_plan)
    safety_row_6(float_plan)
  end

  private

  def safety_row_1(float_plan)
    draw_text 'PFDs:', size: 14, at: [300, 380]
    draw_text (float_plan.pfds ? 'Yes' : 'No'), size: 12, at: [360, 380]
    draw_text 'Flares:', size: 14, at: [420, 380]
    draw_text (float_plan.flares ? 'Yes' : 'No'), size: 12, at: [520, 380]
  end

  def safety_row_2(float_plan)
    draw_text 'Mirror:', size: 14, at: [300, 360]
    draw_text (float_plan.mirror ? 'Yes' : 'No'), size: 12, at: [360, 360]
    draw_text 'Horn:', size: 14, at: [420, 360]
    draw_text (float_plan.horn ? 'Yes' : 'No'), size: 12, at: [520, 360]
  end

  def safety_row_3(float_plan)
    draw_text 'Smoke:', size: 14, at: [300, 340]
    draw_text (float_plan.smoke ? 'Yes' : 'No'), size: 12, at: [360, 340]
    draw_text 'Flashlight:', size: 14, at: [420, 340]
    draw_text (float_plan.flashlight ? 'Yes' : 'No'), size: 12, at: [520, 340]
  end

  def safety_row_4(float_plan)
    draw_text 'EPIRB:', size: 14, at: [300, 320]
    draw_text (float_plan.epirb ? 'Yes' : 'No'), size: 12, at: [360, 320]
    draw_text 'Raft / Dinghy:', size: 14, at: [420, 320]
    draw_text (float_plan.raft ? 'Yes' : 'No'), size: 12, at: [520, 320]
  end

  def safety_row_5(float_plan)
    draw_text 'Anchor:', size: 14, at: [300, 300]
    draw_text (float_plan.anchor ? 'Yes' : 'No'), size: 12, at: [360, 300]
    draw_text 'Paddles:', size: 14, at: [420, 300]
    draw_text (float_plan.paddles ? 'Yes' : 'No'), size: 12, at: [520, 300]
  end

  def safety_row_6(float_plan)
    draw_text 'Food:', size: 14, at: [300, 280]
    draw_text (float_plan.food ? 'Yes' : 'No'), size: 12, at: [360, 280]
    draw_text 'Water:', size: 14, at: [420, 280]
    draw_text (float_plan.water ? 'Yes' : 'No'), size: 12, at: [520, 280]
  end
end
