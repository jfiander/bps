# frozen_string_literal: true

class Files::FilesController < FileController
  TYPE ||= :file
  MODEL_CLASS ||= MarkdownFile

  include Concerns::Application::RedirectWithStatus

  secure!(:page)

  title!('Files')

  def new
    @file = MODEL_CLASS.new
    @markdown_files = MODEL_CLASS.all
  end

private

  def file_params
    params.require(:markdown_file).permit(:file)
  end
end
