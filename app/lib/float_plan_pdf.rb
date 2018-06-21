class FloatPlanPDF < Prawn::Document
  include FontAwesomeHelper

  def self.for(float_plan)
    FloatPlanPDF.generate('tmp/Float_Plan.pdf') do
      sheet(float_plan)
    end

    File.open('tmp/Float_Plan.pdf', 'r+')
  end

  private

  def sheet(float_plan)
    stroke_color '041E42'
    fill_color '041E42'

    header = BpsS3.new(:static).download('logos/ABC.long.birmingham.1000.png')
    File.open('tmp/ABC.long.birmingham.1000.png', 'w+') { |f| f.write(header) }

    image 'tmp/ABC.long.birmingham.1000.png', at: [0, 740], width: 550

    draw_text 'Float Plan', size: 22, at: [220, 630]

    draw_text 'Primary Contact', size: 16, at: [25, 600]
    draw_text 'Name:', size: 14, at: [25, 580]
    draw_text float_plan.name, size: 12, at: [85, 580]
    draw_text 'Phone:', size: 14, at: [25, 560]
    draw_text float_plan.phone, size: 12, at: [85, 560]

    draw_text 'Boat Information', size: 16, at: [300, 600]
    draw_text 'Type:', size: 14, at: [300, 580]
    draw_text float_plan.boat_type, size: 12, at: [360, 580]
    draw_text "(#{float_plan.subtype})", size: 12, at: [380, 580] if float_plan.subtype.present?
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

    draw_text 'Safety Equipment', size: 16, at: [300, 400]
    draw_text 'PFDs:', size: 14, at: [300, 380]
    draw_text (float_plan.pfds ? 'Yes' : 'No'), size: 12, at: [360, 380]
    draw_text 'Flares:', size: 14, at: [420, 380]
    draw_text (float_plan.flares ? 'Yes' : 'No'), size: 12, at: [520, 380]

    draw_text 'Mirror:', size: 14, at: [300, 360]
    draw_text (float_plan.mirror ? 'Yes' : 'No'), size: 12, at: [360, 360]
    draw_text 'Horn:', size: 14, at: [420, 360]
    draw_text (float_plan.horn ? 'Yes' : 'No'), size: 12, at: [520, 360]

    draw_text 'Smoke:', size: 14, at: [300, 340]
    draw_text (float_plan.smoke ? 'Yes' : 'No'), size: 12, at: [360, 340]
    draw_text 'Flashlight:', size: 14, at: [420, 340]
    draw_text (float_plan.flashlight ? 'Yes' : 'No'), size: 12, at: [520, 340]

    draw_text 'EPIRB:', size: 14, at: [300, 320]
    draw_text (float_plan.epirb ? 'Yes' : 'No'), size: 12, at: [360, 320]
    draw_text 'Raft / Dinghy:', size: 14, at: [420, 320]
    draw_text (float_plan.raft ? 'Yes' : 'No'), size: 12, at: [520, 320]

    draw_text 'Anchor:', size: 14, at: [300, 300]
    draw_text (float_plan.anchor ? 'Yes' : 'No'), size: 12, at: [360, 300]
    draw_text 'Paddles:', size: 14, at: [420, 300]
    draw_text (float_plan.paddles ? 'Yes' : 'No'), size: 12, at: [520, 300]

    draw_text 'Food:', size: 14, at: [300, 280]
    draw_text (float_plan.food ? 'Yes' : 'No'), size: 12, at: [360, 280]
    draw_text 'Water:', size: 14, at: [420, 280]
    draw_text (float_plan.water ? 'Yes' : 'No'), size: 12, at: [520, 280]

    draw_text 'Communication', size: 16, at: [25, 520]
    draw_text 'EPIRB Freqs:', size: 14, at: [25, 500]
    draw_text [(float_plan.epirb_16 ? 'Ch 15/16' : nil), (float_plan.epirb_1215 ? '121.5 MHz' : nil), (float_plan.epirb_406 ? '406 MHz' : nil)].compact.join(' / '), size: 12, at: [120, 500]
    draw_text 'Radio Bands:', size: 14, at: [25, 480]
    draw_text [(float_plan.radio_vhf ? 'VHF' : nil), (float_plan.radio_ssb ? 'SSB' : nil), (float_plan.radio_cb ? 'CB' : nil), (float_plan.radio_cell_phone ? 'Cell Phone' : nil)].compact.join(' / '), size: 12, at: [120, 480]
    draw_text 'Monitoring:', size: 14, at: [25, 460]
    draw_text float_plan.channels_monitored, size: 12, at: [120, 460]
    draw_text 'Call Sign:', size: 14, at: [25, 440]
    draw_text float_plan.call_sign, size: 12, at: [120, 440]
    if float_plan.radio.present?
      draw_text 'Radio:', size: 14, at: [25, 420]
      draw_text float_plan.radio, size: 12, at: [25, 420]
      left_vertical_offset = 0
    else
      left_vertical_offset = 20
    end

    draw_text 'Route Plan', size: 16, at: [25, (380 + left_vertical_offset)]
    draw_text 'Leave From:', size: 14, at: [25, (360 + left_vertical_offset)]
    draw_text float_plan.leave_from, size: 12, at: [120, (360 + left_vertical_offset)]
    draw_text 'Going To:', size: 14, at: [25, (340 + left_vertical_offset)]
    draw_text float_plan.going_to, size: 12, at: [120, (340 + left_vertical_offset)]
    draw_text 'Leave At:', size: 14, at: [25, (320 + left_vertical_offset)]
    draw_text float_plan.leave_at, size: 12, at: [120, (320 + left_vertical_offset)]
    draw_text 'Return At:', size: 14, at: [25, (300 + left_vertical_offset)]
    draw_text float_plan.return_at, size: 12, at: [120, (300 + left_vertical_offset)]
    fill_color 'CC0000'
    draw_text 'Alert At:', size: 14, at: [25, (280 + left_vertical_offset)]
    draw_text float_plan.alert_at, size: 12, at: [120, (280 + left_vertical_offset)]
    draw_text 'Alert:', size: 14, at: [25, (260 + left_vertical_offset)]
    draw_text float_plan.alert_name, size: 12, at: [120, (260 + left_vertical_offset)]
    if float_plan.alert_phone.present?
      draw_text 'Phone:', size: 14, at: [25, (240 + left_vertical_offset)]
      draw_text float_plan.alert_phone, size: 12, at: [120, (240 + left_vertical_offset)]
    else
      left_vertical_offset += 20
    end
    fill_color '041E42'

    car_fields = [
      float_plan.car_make, float_plan.car_model, float_plan.car_license_plate,
      float_plan.trailer_license_plate, float_plan.car_parked_at
    ]
    draw_text 'Ground Transportation', size: 16, at: [25, (200 + left_vertical_offset)]
    if car_fields.any?(&:present?)
      draw_text 'Car:', size: 14, at: [25, (180 + left_vertical_offset)]
      draw_text [float_plan.car_make, float_plan.car_model, float_plan.car_year, float_plan.car_color].reject(&:blank?).join(' / '), size: 12, at: [120, (180 + left_vertical_offset)]
      draw_text 'License:', size: 14, at: [25, (160 + left_vertical_offset)]
      draw_text float_plan.car_license_plate, size: 12, at: [120, (160 + left_vertical_offset)]
      if float_plan.trailer_license_plate.present?
        draw_text 'Trailer License:', size: 14, at: [25, (140 + left_vertical_offset)]
        draw_text float_plan.trailer_license_plate, size: 12, at: [120, (140 + left_vertical_offset)]
      else
        left_vertical_offset += 20
      end
      draw_text 'Parked At:', size: 14, at: [25, (120 + left_vertical_offset)]
      draw_text float_plan.car_parked_at, size: 12, at: [120, (120 + left_vertical_offset)]
    else
      draw_text 'n/a', size: 14, at: [25, (180 + left_vertical_offset)]
    end

    onboard_y = 220
    draw_text 'Persons Onboard', size: 16, at: [300, 240]
    float_plan.onboard.each_with_index do |person, i|
      draw_text "#{person.name} (#{person.age})", size: 12, at: [300, onboard_y]
      if person.phone.present?
        onboard_y -= 20
        draw_text person.phone, size: 12, at: [320, onboard_y]
      end
      if person.address.present?
        onboard_y -= 20
        draw_text person.address, size: 12, at: [320, onboard_y]
      end
      onboard_y -= 20
    end

    draw_text 'Comments:', size: 14, at: [25, (60 + left_vertical_offset)]
    bounding_box([25, (40 + left_vertical_offset)], width: 500, height: (50 + left_vertical_offset)) do
      text float_plan.comments, size: 12
    end
  end
end
