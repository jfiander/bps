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
    draw_text 'EPIRB Freqs:', size: 14, at: [25, 500]
    draw_text [
      (float_plan.epirb_16 ? 'Ch 15/16' : nil),
      (float_plan.epirb_1215 ? '121.5 MHz' : nil),
      (float_plan.epirb_406 ? '406 MHz' : nil)
    ].compact.join(' / '), size: 12, at: [120, 500]
  end

  def radio_bands(float_plan)
    draw_text 'Radio Bands:', size: 14, at: [25, 480]
    draw_text [
      (float_plan.radio_vhf ? 'VHF' : nil),
      (float_plan.radio_ssb ? 'SSB' : nil),
      (float_plan.radio_cb ? 'CB' : nil),
      (float_plan.radio_cell_phone ? 'Cell Phone' : nil)
    ].compact.join(' / '), size: 12, at: [120, 480]
  end

  def radio_call_info(float_plan)
    draw_text 'Monitoring:', size: 14, at: [25, 460]
    draw_text float_plan.channels_monitored, size: 12, at: [120, 460]
    draw_text 'Call Sign:', size: 14, at: [25, 440]
    draw_text float_plan.call_sign, size: 12, at: [120, 440]
  end

  def radio_comments(float_plan)
    if float_plan.radio.present?
      draw_text 'Radio:', size: 14, at: [25, 420]
      draw_text float_plan.radio, size: 12, at: [25, 420]
      @left_vertical_offset = 0
    else
      @left_vertical_offset = 20
    end
  end
end
