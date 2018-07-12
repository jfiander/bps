# frozen_string_literal: true

class FileController < ApplicationController
  include Concerns::Application::RedirectWithStatus

  secure!(:page)

  title!('Files', only: %i[new create destroy])
  title!('Headers', only: %i[new_header create_header destroy_header])

  def new
    @file = MarkdownFile.new
    @markdown_files = MarkdownFile.all
  end

  def create
    upload_file
  end

  def destroy
    remove_file
  end

  def new_header
    @header = HeaderImage.new
    @headers = HeaderImage.all
  end

  def create_header
    upload_file(:header)
  end

  def destroy_header
    remove_file(:header)
  end

  private

  def file_params
    params.require(:markdown_file).permit(:file)
  end

  def header_params
    params.require(:header_image).permit(:file)
  end

  def destroy_params
    params.permit(:id)
  end

  def upload_file(type = :file)
    @uploaded_file = if type == :file
                       MarkdownFile.create(file_params)
                     elsif type == :header
                       HeaderImage.create(header_params)
                     end

    redirect_with_status(send("#{type}_path"), object: type, verb: 'upload', past: 'uploaded', ivar: @uploaded_file) do
      @uploaded_file.valid?
    end
  end

  def remove_file(type = :file)
    @file = if type == :file
              MarkdownFile.find_by(id: destroy_params[:id])
            elsif type == :header
              HeaderImage.find_by(id: destroy_params[:id])
            end

    redirect_with_status(send("#{type}_path"), object: type, verb: 'remove', ivar: @file) do
      @file.destroy
    end
  end
end
