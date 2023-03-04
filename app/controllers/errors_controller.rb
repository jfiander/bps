# frozen_string_literal: true

class ErrorsController < ApplicationController
  before_action :default_format

  def not_found
    respond_to do |format|
      format.html { render(status: :not_found) }
      format.json { render(json: { error: 'Page not found.' }, status: :not_found) }
    end
  end

  def not_acceptable
    respond_to do |format|
      format.html { render(status: :not_acceptable) }
      format.json { render(json: { error: 'Format not supported.' }, status: :not_acceptable) }
    end
  end

  def internal_server_error
    respond_to do |format|
      format.html { render(status: :internal_server_error) }
      format.json do
        render(json: { error: 'Internal server error.' }, status: :internal_server_error)
      end
    end
  end

private

  def default_format
    request.format = params[:format].in?(%w[json js]) ? 'json' : 'html'
  end
end
