class MainController < ApplicationController
  before_action :authenticate_user!, only: [:members]
  before_action                      only: [:admin] { require_permission(:admin) }

  def index
    #
  end

  def members
    #
  end

  def admin
    #
  end

  private
  def clean_params
    params.permit()
  end
end
