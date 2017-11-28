class MembersController < ApplicationController
  before_action :authenticate_user!
  before_action                   only: [:admin, :download_flags] { require_permission(:admin) }
  before_action                   only: [:upload_bilge] { require_permission(:newsletter) }
  before_action                   only: [:edit_markdown, :update_markdown] { require_permission(:page) }

  before_action :get_bilge_issue, only: [:upload_bilge, :remove_bilge]
  before_action :render_markdown, only: [:members]

  def members
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

  def edit_markdown
    @page = StaticPage.find_by(name: clean_params[:page_name])
  end

  def update_markdown
    page = StaticPage.find_by(name: static_page_params[:name])

    if page.update(markdown: static_page_params[:markdown])
      redirect_to send("#{page.name}_path"), notice: "Successfully updated #{page.name} page."
    else
      redirect_to send("#{page.name}_path"), alert: "Unable to update #{page.name} page."
    end
  end

  private
  def clean_params
    params.permit(:page_name, :bilge_upload_file, :bilge_remove, issue: ['date(1i)', 'date(2i)'])
  end

  def static_page_params
    params.require(:static_page).permit(:name, :markdown)
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
