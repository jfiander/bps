class MembersController < ApplicationController
  before_action :authenticate_user!
  before_action only: [:admin] { require_permission(:admin) }
  before_action only: [:upload_bilge] { require_permission(:newsletter) }

  def index
    #
  end

  def admin
    #
  end

  def upload_bilge
    year = clean_params[:issue]['date(1i)']
    month = clean_params[:issue]['date(2i)']
    month = "s" if month.to_i.in? [7,8]
    BpsS3.upload(clean_params[:bilge_upload_file], bucket: :bilge, key: "#{year}/#{month}.pdf")
    redirect_to bilge_path, notice: "Bilge Chatter uploaded successfully."
  end

  private
  def clean_params
    params.permit(:bilge_upload_file, issue: ['date(1i)', 'date(2i)'])
  end
end
