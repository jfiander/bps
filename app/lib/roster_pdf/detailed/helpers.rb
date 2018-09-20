# frozen_string_literal: true

module RosterPDF::Detailed::Helpers
  def config_text
    @config_text ||= YAML.safe_load(
      File.read("#{Rails.root}/app/lib/roster_pdf/detailed/text.yml")
    ).deep_symbolize_keys!
  end

  def body_text(string, align: :justify)
    text string.to_s, size: RosterPDF::Detailed::BODY_REG_SIZE, align: align, inline_format: true
  end

  def regular_header
    bounding_box([0, 560], width: 325, height: 15) do
      text(
        "America's Boating Club – Birmingham Squadron",
        size: RosterPDF::Detailed::SECTION_TITLE_SIZE, style: :bold, align: :center, color: 'BF0D3E'
      )

      stroke_line([0, 0], [325, 0])
    end
  end

  def footer
    bounding_box([0, -10], width: 325, height: 25) do
      text 'Copyright © 2018 – Birmingham Power Squadron', size: RosterPDF::Detailed::BODY_SM_SIZE, align: :center
      text 'Member Use Only – Commercial Use Prohibited', size: RosterPDF::Detailed::BODY_SM_SIZE, align: :center, style: :italic
      stroke_line([0, 30], [325, 30])
    end

    bounding_box([285, -10], width: 40, height: 25) do
      text "Page #{page_number}", size: RosterPDF::Detailed::BODY_SM_SIZE, align: :right
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

  def format_name(name)
    if name.to_s&.match?(%r{1st/Lt})
      pre, name = name.split('1st/Lt')
      [{ text: "#{pre}1" }, { text: 'st', styles: [:superscript] }, { text: "/Lt#{name}" }]
    else
      [{ text: name }]
    end
  end

  def roster_entry(user_data, y_offset: 0)
    first = true
    bounding_box([0, 530 - y_offset], width: 325, height: 90) do
      bounding_box([0, 90], width: 155, height: 90) do
        user_data[:left].each do |field|
          if first
            roster_entry_name(field)
            move_down(12)
            first = false
          else
            body_text field
          end
        end
      end
      bounding_box([155, 90], width: 80, height: 90) do
        user_data[:middle].each { |field| body_text(field) }
      end
      bounding_box([235, 90], width: 90, height: 90) do
        user_data[:right].each { |field| body_text(field) }
      end
    end
  end

  def roster_entry_name(name)
    Prawn::Text::Formatted::Box.new(
      format_name(name),
      overflow: :shrink_to_fit, style: :bold, width: 145, height: 15,
      size: RosterPDF::Detailed::HEADING_SIZE, document: self
    ).render
  end
end
