# frozen_string_literal: true

module V2
  class HeadersController < ApplicationController
    include Concerns::Application::RedirectWithStatus

    secure!(:page)

    title!('Headers')

    def index
      @header = HeaderImage.new
      @headers = HeaderImage.all.order(:created_at)
    end

    def create
      @uploaded_file = HeaderImage.create(header_params)

      redirect_with_status(
        v2_headers_path(header: @uploaded_file.id),
        object: :header, verb: 'upload', past: 'uploaded', ivar: @uploaded_file
      ) do
        @uploaded_file.valid?
      end
    end

    def destroy
      @file = HeaderImage.find_by(id: destroy_params[:id])

      redirect_with_status(v2_headers_path, object: :header, verb: 'remove', ivar: @file) do
        @file.destroy
      end
    end

  private

    def header_params
      params.require(:header_image).permit(:file)
    end

    def destroy_params
      params.permit(:id)
    end
  end
end
