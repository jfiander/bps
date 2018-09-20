# frozen_string_literal: true

module RosterPDF::Detailed::RosterInfo
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
    bounding_box([20, 230], width: 125, height: 130) do
      bounding_box([0, 130], width: 25, height: 130) do
        config_text[:roster_info][:grades].keys.each do |abbr|
          text abbr.to_s, size: RosterPDF::Detailed::BODY_REG_SIZE, style: :bold
        end
      end

      bounding_box([25, 130], width: 100, height: 130) do
        config_text[:roster_info][:grades].values.each do |grade|
          body_text grade
        end
      end
    end
  end

  def ranks
    bounding_box([140, 230], width: 200, height: 130) do
      bounding_box([0, 130], width: 40, height: 130) do
        config_text[:roster_info][:ranks].keys.each do |abbr|
          text abbr.to_s, size: RosterPDF::Detailed::BODY_REG_SIZE, style: :bold
        end
      end

      bounding_box([50, 130], width: 160, height: 130) do
        config_text[:roster_info][:ranks].values.each do |rank|
          body_text rank, align: :left
        end
      end
    end
  end

  def entry_format
    text 'Roster Entry Format', size: RosterPDF::Detailed::HEADING_SIZE, style: :bold, align: :center

    roster_entry(config_text[:roster_info][:format], y_offset: 450)
  end
end
