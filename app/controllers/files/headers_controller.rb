# frozen_string_literal: true

class Files::HeaderController < FileController
  TYPE ||= :header
  MODEL_CLASS ||= HeaderImage

  include Concerns::Application::RedirectWithStatus

  secure!(:page)

  title!('Headers')

  def new
    @header = MODEL_CLASS.new
    @headers = MODEL_CLASS.all
  end

private

  def file_params
    params.require(:header_image).permit(:file)
  end
end
