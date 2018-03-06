class FileController < ApplicationController
  before_action :authenticate_user!
  before_action { require_permission(:page) }

  before_action only: %i[new create destroy] do
    page_title('Files')
  end

  before_action only: %i[new_header create_header destroy_header] do
    page_title('Headers')
  end

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
    uploaded_file = if type == :file
                      MarkdownFile.create(file_params)
                    elsif type == :header
                      HeaderImage.create(header_params)
                    end

    if uploaded_file.valid?
      redirect_to(
        send("#{type}_path"), success: "Successfully uploaded #{type}."
      )
    else
      errors = uploaded_file.errors.full_messages
      redirect_to(
        send("#{type}_path"), alert: "Unable to upload #{type}.", error: errors
      )
    end
  end

  def remove_file(type = :file)
    file = if type == :file
             MarkdownFile.find_by(id: destroy_params[:id])
           elsif type == :header
             HeaderImage.find_by(id: destroy_params[:id])
           end

    if file.destroy
      redirect_to send("#{type}_path"), success: "Successfully removed #{type}."
    else
      redirect_to send("#{type}_path"), alert: "Unable to remove #{type}."
    end
  end
end
