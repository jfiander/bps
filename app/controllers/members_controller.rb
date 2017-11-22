class MembersController < ApplicationController
  before_action :authenticate_user!
  before_action                   only: [:admin, :download_flags] { require_permission(:admin) }
  before_action                   only: [:upload_bilge] { require_permission(:newsletter) }
  before_action :get_bilge_issue, only: [:upload_bilge, :remove_bilge]

  def index
    #
  end

  def upload_bilge
    redirect_to newsletter_path, alert: "You must either upload a file or check the remove box." and return unless clean_params[:bilge_upload_file] || clean_params[:bilge_remove]
    remove_bilge and return if clean_params[:bilge_remove].present?

    BpsS3.upload(clean_params[:bilge_upload_file], bucket: :bilge, key: @key)
    redirect_to newsletter_path, notice: "Bilge Chatter uploaded successfully."
  end

  def download_flags
    BpsS3.download_with_prefix(bucket: :files, prefix: "flags/", to: USPSFlags.configuration.flags_dir)
    redirect_to members_path, notice: "Successfully downloaded flags images."
  end

  private
  def clean_params
    params.permit(:bilge_upload_file, :bilge_remove, issue: ['date(1i)', 'date(2i)'])
  end

  def get_bilge_issue
    @year = clean_params[:issue]['date(1i)']
    month = clean_params[:issue]['date(2i)']
    @month = month.to_i.in?([7,8]) ? "s" : month
    @issue = "#{@year}/#{@month}"
    @key = "#{@issue}.pdf"
  end

  def remove_bilge
    BpsS3.remove_object(bucket: :bilge, key: @key)
    redirect_to newsletter_path, notice: "Bilge Chatter #{@issue} removed successfully."
  end
end
