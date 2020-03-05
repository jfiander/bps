# frozen_string_literal: true

class FileController < ApplicationController
  include Concerns::Application::RedirectWithStatus

  secure!(:page)

  def create
    @uploaded_file = create_file

    redirect_with_status(
      send("#{TYPE}_path", header: @uploaded_file.id),
      object: TYPE, verb: 'upload', past: 'uploaded', ivar: @uploaded_file
    ) do
      @uploaded_file.valid?
    end
  end

  def destroy
    @file = MODEL_CLASS.find_by(id: destroy_params[:id])

    redirect_with_status(header_path, object: TYPE, verb: 'remove', ivar: @file) do
      @file.destroy
    end
  end

private

  def destroy_params
    params.permit(:id)
  end

  def create_file
    MODEL_CLASS.create(file_params)
  end
end
