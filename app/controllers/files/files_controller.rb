# frozen_string_literal: true

module Files
  class FilesController < FileController
    secure!(:page)

    title!('Files')

    def new
      @file = model_class.new
      @markdown_files = model_class.all
    end

  private

    def model_class
      MarkdownFile
    end

    def object_type
      :file
    end

    def file_params
      params.require(:markdown_file).permit(:file)
    end
  end
end
