class FileController < ApplicationController
  before_action { require_permission(:page) }

  def new
    @file = MarkdownFile.new

    @markdown_files = MarkdownFile.all
  end

  def create
    @file = MarkdownFile.create(file_params)

    if @file.valid?
      redirect_to file_path, notice: "Successfully uploaded file."
    else
      redirect_to file_path, alert: "Unable to upload file."
    end
  end

  def destroy
    @file = MarkdownFile.find_by(id: destroy_params[:id])

    if @file.destroy
      redirect_to file_path, notice: "Successfully removed file."
    else
      redirect_to file_path, alert: "Unable to upload file."
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
