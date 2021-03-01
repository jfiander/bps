# frozen_string_literal: true

class FileController < ApplicationController
  include Application::RedirectWithStatus

  secure!(:page)

  def create
    @uploaded_file = create_file

    redirect_with_status(
      send("#{object_type}_path", header: @uploaded_file.id),
      object: object_type, verb: 'upload', past: 'uploaded', ivar: @uploaded_file
    ) do
      @uploaded_file.valid?
    end
  end

  def destroy
    @file = model_class.find_by(id: destroy_params[:id])

    redirect_with_status(header_path, object: object_type, verb: 'remove', ivar: @file) do
      @file.destroy
    end
  end

private

  def model_class
    raise 'Method model_class must be defined by the inheriting class.'
  end

  def object_type
    raise 'Method object_type must be defined by the inheriting class.'
  end

  def destroy_params
    params.permit(:id)
  end

  def create_file
    model_class.create(file_params)
  end
end
