# frozen_string_literal: true

module Application::LayoutAndFormatting
private

  def load_layout_images
    pick_header_image
    @header_logo = static_bucket.link('logos/ABC/png/short/tr/slogan/300.png')
    @print_logo = static_bucket.link('logos/ABC/png/long/tr/birmingham/1000.png')
    @wheel_logo = static_bucket.link('flags/PNG/WHEEL.thumb.png')
    @dca_award = static_bucket.link('logos/DCA_web_2016.png')
  end

  def pick_header_image
    @header_image = files_bucket.link(
      HeaderImage.pick(new_header_params[:header])&.file&.path(:desktop)
    )
  end

  def new_header_params
    params.permit(:header)
  end
end
