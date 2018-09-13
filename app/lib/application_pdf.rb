# frozen_string_literal: true

class ApplicationPDF < Prawn::Document
  private

  def specify_font
    font_families.update(
      'DejaVu Sans' => {
        normal: "#{Rails.root}/app/assets/fonts/DejaVuSans.ttf",
        bold:   "#{Rails.root}/app/assets/fonts/DejaVuSans-Bold.ttf",
        italic: "#{Rails.root}/app/assets/fonts/DejaVuSans-Oblique.ttf"
      }
    )

    font 'DejaVu Sans'
  end

  def configure_colors(color = '232D62')
    stroke_color(color)
    fill_color(color)
  end

  def insert_image(*args)
    image(*args)
  rescue StandardError
    nil
  end
end
