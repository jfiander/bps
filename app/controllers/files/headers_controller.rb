# frozen_string_literal: true

module Files
  class HeaderController < FileController
    secure!(:page)

    title!('Headers')

    def new
      @header = model_class.new
      @headers = model_class.all
    end

  private

    def model_class
      HeaderImage
    end

    def object_type
      :header
    end

    def file_params
      params.require(:header_image).permit(:file)
    end
  end
end
