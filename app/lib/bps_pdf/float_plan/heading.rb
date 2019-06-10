# frozen_string_literal: true

module BpsPdf
  class FloatPlan
    module Heading
      def heading(_)
        load_header_image
        insert_image 'tmp/run/ABC.png', at: [0, 740], width: 550
        draw_text 'Float Plan', size: 22, at: [220, 630]
      end

    private

      def load_header_image
        header = BpsS3.new(:static).download('logos/ABC/png/long/white/birmingham/1000.png')
        File.open('tmp/run/ABC.png', 'w+') { |f| f.write(header) }
      end
    end
  end
end
