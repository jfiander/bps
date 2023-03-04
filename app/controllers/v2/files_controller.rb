# frozen_string_literal: true

module V2
  class FilesController < ApplicationController
    include Concerns::Application::RedirectWithStatus

    secure!(:page)

    title!('Files')

    def index
      @file = MarkdownFile.new
      @markdown_files = MarkdownFile.all
    end

    def create
      @uploaded_file = MarkdownFile.create(file_params)

      redirect_with_status(
        v2_files_path, object: :file, verb: 'upload', past: 'uploaded', ivar: @uploaded_file
      ) do
        @uploaded_file.valid?
      end
    end

    def destroy
      @file = MarkdownFile.find_by(id: destroy_params[:id])

      redirect_with_status(v2_files_path, object: :file, verb: 'remove', ivar: @file) do
        @file.destroy
      end
    end

  private

    def file_params
      params.require(:markdown_file).permit(:file)
    end

    def destroy_params
      params.permit(:id)
    end
  end
end
