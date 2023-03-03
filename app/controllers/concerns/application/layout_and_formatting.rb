# frozen_string_literal: true

module Application
  module LayoutAndFormatting
    # This module defines no public methods.
    def _; end

  private

    def load_layout_images
      pick_header_image
      @logos = {
        light: BPS::S3.new(:static).link('logos/ABC/png/light/long/tr/birmingham/2000.png'),
        dark: BPS::S3.new(:static).link('logos/ABC/png/dark/desat/long/tr/birmingham/2000.png')
      }
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
