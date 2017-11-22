class MembersController < ApplicationController
  before_action :authenticate_user!
  before_action only: [:admin] { require_permission(:admin) }
  before_action :display_admin_menu, only: [:admin, :bilge]

  def index
    #
  end

  def admin
    #
  end

  def bilge
    #
  end

  def upload_bilge
    BpsS3.upload(clean_params[:bilge_upload_file], bucket: :bilge, key: "Bilge_Chatter_#{clean_params[:issue]['date(1i)']}-#{clean_params[:issue]['date(2i)']}.pdf")
    render :bilge, notice: "Bilge Chatter uploaded successfully."
  end

  private
  def display_admin_menu
    @admin_menu = true
  end

  def clean_params
    params.permit(:bilge_upload_file, issue: ['date(1i)', 'date(2i)'])
  end
end
