class MainController < ApplicationController
  before_action :authenticate_user!, only: [:members]

  def index
    #
  end

  def members
    #
  end

  private
  def clean_params
    params.permit()
  end
end
