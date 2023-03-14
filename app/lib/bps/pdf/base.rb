# frozen_string_literal: true

module BPS
  module PDF
    class Base < ::Prawn::Document
      def self.generate(filename, **options)
        timestamp = Time.zone.now.to_i
        full_path = Rails.root.join("tmp/run/#{filename}_#{timestamp}.pdf")
        super(full_path, options)
        full_path
      end

    private

      def specify_font
        font_families.update(
          'DejaVu Sans' => {
            normal: Rails.root.join('app/assets/fonts/DejaVuSans.ttf'),
            bold: Rails.root.join('app/assets/fonts/DejaVuSans-Bold.ttf'),
            italic: Rails.root.join('app/assets/fonts/DejaVuSans-Oblique.ttf')
          }
        )

        font 'DejaVu Sans'
      end

      def specify_font_awesome
        font_families.update(
          { solid: 900, regular: 400, light: 300, brands: 400 }.map do |s, w|
            {
              "FontAwesome Pro #{s.to_s.titleize}" => {
                normal: Rails.root.join("public/webfonts/fa-#{s}-#{w}.ttf")
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
        logo = BPS::S3.new(:static).download('logos/ABC/png/long/white/birmingham/1000.png')
        File.write('tmp/run/ABC-B.png', logo)
      end
    end
  end
end
