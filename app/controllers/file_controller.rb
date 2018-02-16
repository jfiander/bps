class FileController < ApplicationController
  before_action { require_permission(:page) }

  def new
    @file = MarkdownFile.new

    @markdown_files = MarkdownFile.all
  end

  def create
    @file = MarkdownFile.create(file_params)

    if @file.valid?
      redirect_to file_path, notice: 'Successfully uploaded file.'
    else
      redirect_to file_path, alert: 'Unable to upload file.'
    end
  end

  def destroy
    @file = MarkdownFile.find_by(id: destroy_params[:id])

    if @file.destroy
      redirect_to file_path, notice: 'Successfully removed file.'
    else
      redirect_to file_path, alert: 'Unable to upload file.'
    end
  end

  def new_header
    @header = HeaderImage.new

    @headers = HeaderImage.all
  end

  def create_header
    @header = HeaderImage.create(header_params)

    if @header.valid?
      redirect_to header_path, notice: 'Successfully uploaded header image.'
    else
      errors = @header.errors.full_messages.join(', ')
      redirect_to header_path, alert: "Unable to upload header image: #{errors}"
    end
  end

  def destroy_header
    @header = HeaderImage.find_by(id: destroy_params[:id])

    if @header.destroy
      redirect_to header_path, notice: 'Successfully removed header image.'
    else
      redirect_to header_path, alert: 'Unable to upload header image.'
    end
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
end
