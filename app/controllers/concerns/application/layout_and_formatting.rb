# frozen_string_literal: true

module Application::LayoutAndFormatting
private

  def load_layout_images
    pick_header_image
    @header_logo = static_bucket.link('logos/ABC.tr.300.png')
    @print_logo = static_bucket.link('logos/ABC.long.birmingham.1000.png')
    @wheel_logo = static_bucket.link('flags/PNG/WHEEL.thumb.png')
    @dca_award = static_bucket.link('logos/DCA_web_2016.png')
  end

  def pick_header_image
    @header_image = files_bucket.link(find_header&.file&.path(:desktop))
  end

  def find_header
    if new_header_params[:header].present?
      HeaderImage.find_by(id: new_header_params[:header])
    else
      HeaderImage.all.sample
    end
  end

  def new_header_params
    params.permit(:header)
  end
end
