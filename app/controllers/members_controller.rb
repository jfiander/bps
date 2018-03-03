class MembersController < ApplicationController
  include MembersMethods

  before_action :authenticate_user!

  skip_before_action :prerender_for_layout, only: %i[request_item fulfill_item]

  before_action only: [:admin] { require_permission(:admin) }
  before_action only: [:auto_permits] { require_permission(:users) }
  before_action only: [:upload_bilge] { require_permission(:newsletter) }
  before_action only: [:upload_minutes] { require_permission(:minutes) }
  before_action only: [:fulfill_item] { require_permission(:store) }
  before_action(only: %i[edit_markdown update_markdown]) do
    require_permission(:page)
  end
  before_action only: [:ranks] do
    require_permission(%i[users newsletter page minutes event education])
  end

  before_action :bilge_issue, only: %i[upload_bilge remove_bilge]
  before_action :get_minutes_issue, only: %i[upload_minutes remove_minutes]
  before_action :list_minutes, only: %i[minutes get_minutes get_minutes_excom]

  before_action only: [:minutes] { page_title('Minutes') }
  before_action only: [:excom_minutes] { page_title('ExCom Minutes') }
  before_action only: [:edit_markdown] { page_title('Edit Page') }
  before_action only: [:ranks] { page_title('Member Ranks and Grades') }
  before_action only: [:auto_permits] { page_title('Automatic Permissions') }

  render_markdown_views

  def edit_markdown
    @page = StaticPage.find_by(name: clean_params[:page_name])
  end

  def update_markdown
    if clean_params['save']
      save_markdown
    elsif clean_params['preview']
      preview_markdown
      render 'preview_markdown'
    end
  end

  def request_item
    @item_id = clean_params[:id]
    request = current_user.request_from_store(@item_id)
    if request.valid?
      flash[:success] = "Item requested! We'll be in contact with you " \
                        'shortly regarding quantity, payment, and delivery.'
    elsif request.errors.added?(:store_item, :taken)
      flash.now[:alert] = 'You have already requested this item. We will ' \
                          'contact you regarding quantity, payment, and ' \
                          'delivery.'
      render status: :unprocessable_entity
    else
      flash.now[:alert] = 'There was a problem requesting this item.'
      render status: :internal_server_error
    end
  end

  def fulfill_item
    @request_id = clean_params[:id]
    if ItemRequest.find_by(id: @request_id).fulfill
      flash[:success] = 'Item successfully fulfilled!'
    else
      flash.now[:alert] = 'There was a problem fulfilling this item.'
      render status: :internal_server_error
    end
  end

  def ranks
    @users = User.unlocked.with_positions.alphabetized.with_a_name
  end

  def auto_permits
    @auto_permissions = YAML.safe_load(
      File.read("#{Rails.root}/config/implicit_permissions.yml")
    )
  end

  private

  def static_page_params
    params.require(:static_page).permit(:name, :markdown)
  end

  def save_markdown
    page = StaticPage.find_by(name: static_page_params[:name])

    if page.update(markdown: static_page_params[:markdown])
      flash[:success] = "Successfully updated #{page.name} page."
    else
      flash[:alert] = "Unable to update #{page.name} page."
    end
    redirect_to send("#{page.name}_path")
  end

  def preview_markdown
    @page = StaticPage.find_by(name: clean_params[:page_name])
    @new_markdown = static_page_params[:markdown]
    @preview_html = render_markdown_raw(
      markdown: static_page_params[:markdown]
    ).html_safe
  end
end
