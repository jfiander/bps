# frozen_string_literal: true

module BpsPdf::Roster::Detailed::Helpers
  def config_text
    @config_text ||= YAML.safe_load(
      File.read("#{Rails.root}/app/lib/bps_pdf/roster/detailed/text.yml")
    ).deep_symbolize_keys!
  end

  def body_text(string, align: :justify)
    text string.to_s, size: BpsPdf::Roster::Detailed::BODY_REG_SIZE, align: align, inline_format: true
  end

  def regular_header
    bounding_box([0, 560], width: 325, height: 15) do
      text(
        "America's Boating Club – Birmingham Squadron",
        size: BpsPdf::Roster::Detailed::SECTION_TITLE_SIZE, style: :bold, align: :center, color: 'BF0D3E'
      )

      stroke_line([0, 0], [325, 0])
    end
  end

  def footer
    bounding_box([0, -10], width: 325, height: 25) do
      text 'Copyright © 2018 – Birmingham Power Squadron', size: BpsPdf::Roster::Detailed::BODY_SM_SIZE, align: :center
      text 'Member Use Only – Commercial Use Prohibited', size: BpsPdf::Roster::Detailed::BODY_SM_SIZE, align: :center, style: :italic
      stroke_line([0, 30], [325, 30])
    end

    bounding_box([285, -10], width: 40, height: 25) do
      text "Page #{page_number}", size: BpsPdf::Roster::Detailed::BODY_SM_SIZE, align: :right
    end
  end

  def header_footer
    regular_header
    footer
  end

  def formatted_page
    start_new_page
    yield
    header_footer
  end

  def intro_block(heading, message, height)
    bounding_box([0, 540], width: 325, height: height) do
      text heading, size: BpsPdf::Roster::Detailed::SECTION_TITLE_SIZE, style: :bold, align: :center
      move_down(10)
      text message, size: BpsPdf::Roster::Detailed::BODY_REG_SIZE, align: :justify
    end
  end

  def roster_entry(user_data, y_offset: 0)
    bounding_box([0, 530 - y_offset], width: 325, height: 90) do
      roster_entry_left(user_data[:left])
      roster_entry_column(user_data[:middle], 155, 80)
      roster_entry_column(user_data[:right], 235, 90)
    end
  end

  def roster_entry_left(user_data)
    bounding_box([0, 90], width: 155, height: 90) do
      user_data.each_with_index do |field, index|
        roster_entry_left_contents(field, index)
      end
    end
  end

  def roster_entry_left_contents(field, index)
    index.zero? ? roster_entry_left_first(field) : body_text(field, align: :left)
  end

  def roster_entry_left_first(field)
    roster_entry_name(field)
    move_down(12)
  end

  def roster_entry_column(user_data, x_pos, width)
    bounding_box([x_pos, 90], width: width, height: 90) do
      user_data.each { |field| body_text(field, align: :left) }
    end
  end

  def roster_entry_name(name)
    Prawn::Text::Formatted::Box.new(
      format_name(name),
      overflow: :shrink_to_fit, style: :bold, width: 145, height: 15,
      size: BpsPdf::Roster::Detailed::HEADING_SIZE, document: self
    ).render
  end

  def halve(collection)
    collection.each_slice((collection.size / 2.0).round).to_a
  end
end
