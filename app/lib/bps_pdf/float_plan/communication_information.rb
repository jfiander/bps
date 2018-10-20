# frozen_string_literal: true

module BpsPdf::FloatPlan::CommunicationInformation
  def communication_information(float_plan)
    draw_text 'Communication', size: 16, at: [25, 520]
    labeled_text('EPIRB Freqs', float_plan.epirb_freqs, x1: 25, x2: 120, y: 500)
    labeled_text('Radio Bands', float_plan.radio_bands, x1: 25, x2: 120, y: 480)
    labeled_text('Monitoring', float_plan.channels_monitored, x1: 25, x2: 120, y: 460)
    labeled_text('Call Sign', float_plan.call_sign, x1: 25, x2: 120, y: 440)
    radio_comments(float_plan)
  end

private

  def radio_comments(float_plan)
    if float_plan.radio.present?
      labeled_text('Radio', float_plan.radio, x1: 25, x2: 120, y: 420)
      @left_vertical_offset = 0
    else
      @left_vertical_offset = 20
    end
  end
end
