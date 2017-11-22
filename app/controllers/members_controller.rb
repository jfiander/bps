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
    bilges = BpsS3.list(bucket: :bilge)

    @years = bilges.map(&:key).map { |b| b.delete('.pdf').gsub(/\/(s|\d+)/, '') }.uniq

    @bilge_links = bilges.map do |b|
      key = b.key.dup
      issue_date = b.key.delete(".pdf")
      { issue_date => BpsS3.link(bucket: :bilge, key: key) }
    end.reduce({}, :merge)
  end

  def upload_bilge
    year = clean_params[:issue]['date(1i)']
    month = clean_params[:issue]['date(2i)']
    month = "s" if month.to_i.in? [7,8]
    BpsS3.upload(clean_params[:bilge_upload_file], bucket: :bilge, key: "#{year}/#{month}.pdf")
    redirect_to bilge_path, notice: "Bilge Chatter uploaded successfully."
  end

  private
  def display_admin_menu
    @admin_menu = true
  end

  def clean_params
    params.permit(:bilge_upload_file, issue: ['date(1i)', 'date(2i)'])
  end
end
