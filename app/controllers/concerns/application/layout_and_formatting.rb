# frozen_string_literal: true

module Application
  module LayoutAndFormatting
    # This module defines no public methods.
    def _; end

  private

    def load_layout_images
      pick_header_image
      @header_logo = BPS::S3.new(:static).link('logos/ABC/png/short/tr/slogan/300.png')
      @print_logo = BPS::S3.new(:static).link('logos/ABC/png/long/tr/birmingham/2000.png')
      @wheel_logo = BPS::S3.new(:static).link('flags/PNG/WHEEL.thumb.png')
      @dca_award = BPS::S3.new(:static).link('logos/DCA_web_2016.png')
    end

    def pick_header_image
      @header_image = BPS::S3.new(:files).link(
        HeaderImage.pick(new_header_params[:header])&.file&.path(:desktop)
      )
    end

    def new_header_params
      params.permit(:header)
    end
  end
end
