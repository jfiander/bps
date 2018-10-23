# frozen_string_literal: true

module BpsPdf::Roster::Detailed::RosterInfo
  def roster_info
    formatted_page do
      details
      glossary
      grades
      ranks
      entry_format
    end
  end

private

  def details
    bounding_box([0, 540], width: 325, height: 220) do
      config_text[:roster_info][:top].each do |t|
        body_text t
        body_text '<br>'
      end
    end
  end

  def glossary
    bounding_box([0, 320], width: 325, height: 90) do
      config_text[:roster_info][:glossary].each do |key, t|
        body_text "<b>#{key}</b>: #{t}"
        body_text '<br>'
      end
    end
  end

  def grades
    roster_info_table(:grades, 20, 25, [25, 100])
  end

  def ranks
    roster_info_table(:ranks, 140, 50, [40, 160])
  end

  def roster_info_table(key, x_pos, gap, widths)
    bounding_box([x_pos, 230], width: widths.sum, height: 130) do
      roster_info_abbr_table(key, widths[0])
      roster_info_desc_table(key, gap, widths[1])
    end
  end

  def roster_info_abbr_table(key, width)
    bounding_box([0, 130], width: width, height: 130) do
      config_text[:roster_info][key].keys.each do |abbr|
        text abbr.to_s, size: BpsPdf::Roster::Detailed::BODY_REG_SIZE, style: :bold
      end
    end
  end

  def roster_info_desc_table(key, gap, width)
    bounding_box([gap, 130], width: width, height: 130) do
      config_text[:roster_info][key].values.each do |desc|
        body_text desc.to_s, align: :left
      end
    end
  end

  def entry_format
    text(
      'Roster Entry Format',
      size: BpsPdf::Roster::Detailed::HEADING_SIZE, style: :bold, align: :center
    )

    roster_entry(config_text[:roster_info][:format], y_offset: 450)
  end
end
