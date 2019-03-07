# frozen_string_literal: true

module BpsPdf::FloatPlan::SafetyEquipment
  def safety_equipment(float_plan)
    draw_text 'Safety Equipment', size: 16, at: [300, 380]
    safety_row(float_plan, y: 360, left: 'PFDs', right: 'Flares')
    safety_row(float_plan, y: 340, left: 'Mirror', right: 'Horn / Whistle')
    safety_row(float_plan, y: 320, left: 'Smoke', right: 'Flashlight')
    safety_row(float_plan, y: 300, left: 'EPIRB / PLB', right: 'Raft')
    safety_row(float_plan, y: 280, left: 'Anchor', right: 'Paddles')
    safety_row(float_plan, y: 260, left: 'Food', right: 'Water')
  end

private

  def safety_row(float_plan, y:, left:, right:)
    safety_left(left, float_plan.send(left.split(' / ').first.downcase), y)
    safety_right(right, float_plan.send(right.split(' / ').first.downcase), y)
  end

  def safety_left(left, equipped, y)
    safety_color(equipped) do
      labeled_text(left, equipped ? 'Yes' : 'No', x1: 300, x2: 390, y: y)
    end
  end

  def safety_right(right, equipped, y)
    safety_color(equipped) do
      labeled_text(right, equipped ? 'Yes' : 'No', x1: 420, x2: 520, y: y)
    end
  end

  def safety_color(equipped)
    if equipped
      configure_colors('009900')
      yield
      configure_colors
    else
      configure_colors('990000')
      yield
      configure_colors
    end
  end
end
