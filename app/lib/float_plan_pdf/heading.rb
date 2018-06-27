# frozen_string_literal: true

module FloatPlanPDF::Heading
  def heading(_)
    load_header_image
    image 'tmp/ABC.long.birmingham.1000.png', at: [0, 740], width: 550
    draw_text 'Float Plan', size: 22, at: [220, 630]
  end

  private

  def load_header_image
    header = BpsS3.new(:static).download('logos/ABC.long.birmingham.1000.png')
    File.open('tmp/ABC.long.birmingham.1000.png', 'w+') { |f| f.write(header) }
  end
end