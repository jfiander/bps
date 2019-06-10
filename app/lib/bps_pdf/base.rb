# frozen_string_literal: true

module BpsPdf
  class Base < Prawn::Document
    # This class defines no public methods.
    def _; end

  private

    def specify_font
      font_families.update(
        'DejaVu Sans' => {
          normal: "#{Rails.root}/app/assets/fonts/DejaVuSans.ttf",
          bold: "#{Rails.root}/app/assets/fonts/DejaVuSans-Bold.ttf",
          italic: "#{Rails.root}/app/assets/fonts/DejaVuSans-Oblique.ttf"
        }
      )

      font 'DejaVu Sans'
    end

    def specify_font_awesome
      font_families.update(
        { solid: 900, regular: 400, light: 300, brands: 400 }.map do |s, w|
          {
            "FontAwesome Pro #{s.to_s.titleize}" => {
              normal: "#{Rails.root}/public/webfonts/fa-#{s}-#{w}.ttf"
            }
          }
        end.reduce({}, :merge)
      )
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
      logo = BpsS3.new(:static).download('logos/ABC/png/long/white/birmingham/1000.png')
      File.open('tmp/run/ABC-B.png', 'w+') { |f| f.write(logo) }
    end
  end
end
