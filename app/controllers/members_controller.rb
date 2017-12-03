class MembersController < ApplicationController
  before_action :authenticate_user!
  before_action                   only: [:admin, :download_flags] { require_permission(:admin) }
  before_action                   only: [:upload_bilge] { require_permission(:newsletter) }
  before_action                   only: [:edit_markdown, :update_markdown] { require_permission(:page) }

  MARKDOWN_EDITABLE_VIEWS ||= [:members].freeze

  before_action :get_bilge_issue,   only: [:upload_bilge, :remove_bilge]
  before_action :get_minutes_issue, only: [:upload_minutes, :remove_minutes]
  before_action :render_markdown,   only: MARKDOWN_EDITABLE_VIEWS
  before_action :list_minutes,      only: [:minutes, :get_minutes, :get_minutes_excom]

  MARKDOWN_EDITABLE_VIEWS.each { |m| define_method(m) {} }

  def minutes
    minutes_years = @minutes.map(&:key).map { |b| b.sub(minutes_prefix, '').delete('.pdf').gsub(/\/(s|\d+)/, '') }
    minutes_excom_years = @minutes_excom.map(&:key).map { |b| b.sub(minutes_prefix(excom: true), '').delete('.pdf').gsub(/\/(s|\d+)/, '') }

    @years = [minutes_years, minutes_excom_years].flatten.uniq
    @issues = @minutes_links.keys
    @issues_excom = @minutes_excom_links.keys
    @available_issues = {
      1   => "Jan",
      2   => "Feb",
      3   => "Mar",
      4   => "Apr",
      5   => "May",
      6   => "Jun",
      9   => "Sep",
      10  => "Oct",
      11  => "Nov",
      12  => "Dec"
    }
  end

  def get_minutes
    key = "#{minutes_prefix}#{minutes_params[:year]}/#{minutes_params[:month]}"
    issue_link = @minutes_links[key.sub(minutes_prefix, '')]
    issue_title = key.gsub("/", "-")

    begin
      send_data open(issue_link).read, filename: "BPS Minutes #{issue_title}.pdf", type: "application/pdf", disposition: 'inline'
    rescue SocketError => e
      minutes
      render :minutes, alert: "There was a problem accessing the minutes. Please try again later."
    end
  end

  def get_minutes_excom
    key = "#{minutes_prefix(excom: true)}#{minutes_params[:year]}/#{minutes_params[:month]}"
    issue_link = @minutes_excom_links[key.sub(minutes_prefix(excom: true), '')]
    issue_title = key.gsub("/", "-")

    begin
      send_data open(issue_link).read, filename: "BPS ExCom Minutes #{issue_title}.pdf", type: "application/pdf", disposition: 'inline'
    rescue SocketError => e
      minutes
      render :minutes, alert: "There was a problem accessing the minutes. Please try again later."
    end
  end

  def upload_minutes
    redirect_to minutes_path, alert: "You must either upload a file or check the remove box." and return unless minutes_params[:minutes_upload_file] || minutes_params[:minutes_remove]
    remove_minutes and return if minutes_params[:minutes_remove].present?

    files_bucket.upload(file: minutes_params[:minutes_upload_file], key: @key)
    redirect_to minutes_path, notice: "Minutes #{@issue} uploaded successfully."
  end

  def upload_bilge
    redirect_to newsletter_path, alert: "You must either upload a file or check the remove box." and return unless clean_params[:bilge_upload_file] || clean_params[:bilge_remove]
    remove_bilge and return if clean_params[:bilge_remove].present?

    bilge_bucket.upload(file: clean_params[:bilge_upload_file], key: @key)
    redirect_to newsletter_path, notice: "Bilge Chatter #{@issue} uploaded successfully."
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

  def request_item
    @item_id = clean_params[:id]
    request = current_user.request_from_store(@item_id)
    if request.valid?
      flash[:notice] = "Item requested! We'll be in contact with you shortly regarding quantity, payment, and delivery."
    elsif request.errors.added?(:store_item, :taken)
      flash[:alert] = "You have already requested this item. We will contact you regarding quantity, payment, and delivery"
      render status: :unprocessable_entity
    else
      flash[:alert] = "There was a problem requesting this item."
      render status: :internal_server_error
    end
  end

  def fulfill_item
    @request_id = clean_params[:id]
    if ItemRequest.find_by(id: @request_id).fulfill
      flash[:notice] = "Item successfully fulfilled!"
    else
      flash[:alert] = "There was a problem fulfilling this item."
      render status: :internal_server_error
    end
  end

  private
  def clean_params
    params.permit(:id, :page_name, :bilge_upload_file, :bilge_remove, issue: ['date(1i)', 'date(2i)'])
  end

  def static_page_params
    params.require(:static_page).permit(:name, :markdown)
  end

  def minutes_params
    params.permit(:minutes_upload_file, :minutes_remove, :minutes_excom, :year, :month, issue: ['date(1i)', 'date(2i)'])
  end

  def get_bilge_issue
    @year = clean_params[:issue]['date(1i)']
    month = clean_params[:issue]['date(2i)']
    @month = month.to_i.in?([7,8]) ? "s" : month
    @issue = "#{@year}/#{@month}"
    @key = "#{@issue}.pdf"
  end

  def remove_bilge
    bilge_bucket.remove_object(key: @key)
    redirect_to newsletter_path, notice: "Bilge Chatter #{@issue} removed successfully."
  end

  def remove_minutes
    files_bucket.remove_object(key: @key)
    redirect_to minutes_path, notice: "Minutes #{@issue} removed successfully."
  end

  def get_minutes_issue
    excom = minutes_params[:minutes_excom]
    @year = minutes_params[:issue]['date(1i)']
    month = minutes_params[:issue]['date(2i)']
    @month = month.to_i.in?([7,8]) ? "s" : month
    @issue = "#{@year}/#{@month}"
    @key = "#{minutes_prefix(excom: excom)}#{@issue}.pdf"
  end

  def list_minutes
    @minutes = files_bucket.list(prefix: minutes_prefix)
    @minutes_excom = files_bucket.list(prefix: minutes_prefix(excom: true))

    @minutes_links = @minutes.map do |m|
      key = m.key.dup
      issue_date = m.key.sub(minutes_prefix, '').delete(".pdf")
      { issue_date => files_bucket.link(key: key) }
    end.reduce({}, :merge)

    @minutes_excom_links = @minutes_excom.map do |m|
      key = m.key.dup
      issue_date = m.key.sub(minutes_prefix(excom: true), '').delete(".pdf")
      { issue_date => files_bucket.link(key: key) }
    end.reduce({}, :merge)
  end

  def minutes_prefix(excom: false)
    excom_prefix = excom ? "excom_" : ""
    "#{excom_prefix}minutes/"
  end
end
