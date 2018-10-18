# frozen_string_literal: true

module BpsPdf
  class Base < Prawn::Document
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

    def load_logo
      logo = BpsS3.new(:static).download('logos/ABC.long.birmingham.1000.png')
      File.open('tmp/run/ABC-B.png', 'w+') { |f| f.write(logo) }
    end
  end
end
