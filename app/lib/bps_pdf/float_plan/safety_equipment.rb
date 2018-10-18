# frozen_string_literal: true

module BpsPdf::FloatPlan::SafetyEquipment
  def safety_equipment(float_plan)
    draw_text 'Safety Equipment', size: 16, at: [300, 400]
    safety_row(float_plan, y: 380, left: 'PFDs', right: 'Flares')
    safety_row(float_plan, y: 360, left: 'Mirror', right: 'Horn / Whistle')
    safety_row(float_plan, y: 340, left: 'Smoke', right: 'Flashlight')
    safety_row(float_plan, y: 320, left: 'EPIRB / PLB', right: 'Raft')
    safety_row(float_plan, y: 300, left: 'Anchor', right: 'Paddles')
    safety_row(float_plan, y: 280, left: 'Food', right: 'Water')
  end

  private

  def safety_row(float_plan, y:, left:, right:)
    left_answer = (float_plan.send(left.split(' / ').first.downcase) ? 'Yes' : 'No')
    right_answer = (float_plan.send(right.split(' / ').first.downcase) ? 'Yes' : 'No')

    labeled_text(left, left_answer, x1: 300, x2: 390, y: y)
    labeled_text(right, right_answer, x1: 420, x2: 520, y: y)
  end
end
