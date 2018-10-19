# frozen_string_literal: true

module BpsPdf::Roster::Detailed::Cover
  def cover
    load_logo
    insert_image 'tmp/run/ABC-B.png', at: [0, 550], width: 325
    roster_title
    timestamp
    footer
    move_up(470) # Return to below heading for text span
    cover_text # Wraps past footer
    header_footer
  end

  private

  def roster_title
    bounding_box([0, 490], width: 325, height: 35) do
      text 'Membership Roster', size: BpsPdf::Roster::Detailed::TITLE_SIZE, style: :bold, align: :center
    end
  end

  def timestamp
    ts = Time.now.in_time_zone.strftime(ApplicationController::MEDIUM_TIME_FORMAT)
    bounding_box([0, 470], width: 325, height: 35) do
      text "Generated: #{ts}", size: BpsPdf::Roster::Detailed::SECTION_TITLE_SIZE, align: :center
    end
  end

  def cover_text
    span(325) do
      config_text[:cover][:top].each do |t|
        text(t, size: BpsPdf::Roster::Detailed::BODY_REG_SIZE, inline_format: true, align: :justify)
        text('<br>', size: BpsPdf::Roster::Detailed::BODY_REG_SIZE, inline_format: true)
      end

      config_text[:cover][:sections].each do |h, t|
        text("<b>#{h}</b>: #{t}", size: BpsPdf::Roster::Detailed::BODY_REG_SIZE, inline_format: true, align: :justify)
        text('<br>', size: BpsPdf::Roster::Detailed::BODY_REG_SIZE, inline_format: true)
      end
    end
  end
end
