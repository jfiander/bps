# frozen_string_literal: true

module FloatPlanPDF::CommunicationInformation
  def communication_information(float_plan)
    draw_text 'Communication', size: 16, at: [25, 520]
    epirb_details(float_plan)
    radio_bands(float_plan)
    radio_call_info(float_plan)
    radio_comments(float_plan)
  end

  private

  def epirb_details(float_plan)
    labeled_text(
      'EPIRB Freqs',
      [
        (float_plan.epirb_16 ? 'Ch 15/16' : nil),
        (float_plan.epirb_1215 ? '121.5 MHz' : nil),
        (float_plan.epirb_406 ? '406 MHz' : nil)
      ].compact.join(' / '),
      x1: 25, x2: 120, y: 500
    )
  end

  def radio_bands(float_plan)
    labeled_text(
      'Radio Bands',
      [
        (float_plan.radio_vhf ? 'VHF' : nil),
        (float_plan.radio_ssb ? 'SSB' : nil),
        (float_plan.radio_cb ? 'CB' : nil),
        (float_plan.radio_cell_phone ? 'Cell Phone' : nil)
      ].compact.join(' / '),
      x1: 25, x2: 120, y: 480
    )
  end

  def radio_call_info(float_plan)
    labeled_text('Monitoring', float_plan.channels_monitored, x1: 25, x2: 120, y: 460)
    labeled_text('Call Sign', float_plan.call_sign, x1: 25, x2: 120, y: 440)
  end

  def radio_comments(float_plan)
    if float_plan.radio.present?
      labeled_text('Radio', float_plan.radio, x1: 25, x2: 120, y: 420)
      @left_vertical_offset = 0
    else
      @left_vertical_offset = 20
    end
  end
end
