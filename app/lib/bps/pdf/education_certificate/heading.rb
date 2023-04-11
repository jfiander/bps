# frozen_string_literal: true

module BPS
  module PDF
    class EducationCertificate
      module Heading
        def heading(_, **_)
          load_header_image
          insert_image 'tmp/run/Wheel.500.png', at: [0, 730], width: 125
          title_text
        end

      private

        def load_header_image
          header = BPS::S3.new(:static).download('flags/PNG/WHEEL.500.png')
          File.write('tmp/run/Wheel.500.png', header)
        end

        def title_text
          title_usps
          title_slogan
          title_certificate
        end

        def title_usps
          bounding_box([150, 715], width: 390, height: 35) do
            text(
              'United States Power Squadrons<sup>®</sup>',
              size: 21, inline_format: true, style: :bold
            )
          end
        end

        def title_slogan
          bounding_box([150, 685], width: 390, height: 20) do
            text(
              'For Boaters, By Boaters.<sup>®</sup>',
              size: 12, inline_format: true, style: :italic
            )
          end
        end

        def title_certificate
          self.line_width = 2
          stroke_line([150, 660], [540, 660])
          self.line_width = 1
          bounding_box([150, 640], width: 390, height: 20) do
            text 'Certificate of Achievement', size: 16, style: :bold
          end
        end
      end
    end
  end
end
