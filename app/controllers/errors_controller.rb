# frozen_string_literal: true

class ErrorsController < ApplicationController
  before_action :default_format

  def not_found
    respond_to do |format|
      format.html { render(status: 404) }
      format.json { render(json: { error: 'Page not found.' }, status: 404) }
    end
  end

  def not_acceptable
    respond_to do |format|
      format.html { render(status: 406) }
      format.json { render(json: { error: 'Format not supported.' }, status: 406) }
    end
  end

  def internal_server_error
    respond_to do |format|
      format.html { render(status: 500) }
      format.json { render(json: { error: 'Internal server error.' }, status: 500) }
    end
  end

private

  def default_format
    request.format = params[:format].in?(%w[json js]) ? 'json' : 'html'
  end
end
