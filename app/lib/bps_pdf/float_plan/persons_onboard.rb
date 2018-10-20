# frozen_string_literal: true

module BpsPdf::FloatPlan::PersonsOnboard
  def persons_onboard(float_plan)
    @onboard_y = 220
    configure_colors('000099')
    draw_text 'Persons Onboard', size: 16, at: [300, 240]
    float_plan.onboard.each { |person| person_onboard(person) }
    configure_colors
  end

private

  def person_onboard(person)
    draw_text "#{person.name} (#{person.age})", size: 12, at: [300, @onboard_y]
    if person.phone.present?
      @onboard_y -= 20
      draw_text person.phone, size: 12, at: [320, @onboard_y]
    end
    if person.address.present?
      @onboard_y -= 20
      draw_text person.address, size: 12, at: [320, @onboard_y]
    end
    @onboard_y -= 20
  end
end
