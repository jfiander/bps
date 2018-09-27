# frozen_string_literal: true

class MembersController < ApplicationController
  include Members::Bilge
  include Members::Minutes
  include Members::Roster
  include BraintreeHelper

  secure!
  secure!(:admin, only: :admin)
  secure!(:newsletter, only: :upload_bilge)
  secure!(:minutes, only: :upload_minutes)
  secure!(:store, only: :fulfill_item)
  secure!(:roster, only: %i[update_roster upload_roster])
  secure!(:page, only: %i[edit_markdown update_markdown])
  secure!(%i[users newsletter page minutes event education], only: %i[ranks])

  before_action :redirect_to_root, only: :dues, unless: :braintree_enabled?
  before_action :prepare_dues, only: :dues, if: :current_user_dues_due?

  before_action :list_minutes, only: %i[minutes get_minutes get_minutes_excom]

  before_action :generate_client_token, only: :applied
  before_action :block_duplicate_payments, only: :applied, if: :already_paid?

  title!('Minutes', only: :minutes)
  title!('ExCom Minutes', only: :excom_minutes)
  title!('Edit Page', only: :edit_markdown)
  title!('Member Ranks and Grades', only: :ranks)
  title!('Automatic Permissions', only: :auto_permits)

  render_markdown_views

  def edit_markdown
    @page = StaticPage.find_by(name: clean_params[:page_name])
  end

  def update_markdown
    clean_params['markdown'] = sanitize(clean_params['markdown'])
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
    @users = User.unlocked.include_positions.alphabetized.with_any_name
  end

  def dues
    dues_not_payable unless @payment.present?
  end

  private

  def current_user_dues_due?
    current_user&.dues_due?
  end

  def prepare_dues
    @payment = Payment.recent.for_user(current_user).first
    @payment ||= Payment.create(parent_type: 'User', parent_id: current_user.id)
    transaction_details
    set_dues_instance_variables
  end

  def set_dues_instance_variables
    @token = @payment.token
    @client_token = Payment.client_token(user_id: current_user&.id)
    @receipt = current_user.email
  end

  def dues_not_payable
    if current_user.parent_id.present?
      flash[:alert] = 'Additional household members cannot pay dues.'
    else
      flash[:notice] = 'Your dues for this year are not yet due.'
    end
    redirect_to root_path
  end

  def static_page_params
    params.require(:static_page).permit(:name, :markdown)
  end

  def clean_params
    params.permit(:page_name, :id, :save, :preview)
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
    # html_safe: Text is sanitized before display
    @page = StaticPage.find_by(name: clean_params[:page_name])
    @new_markdown = sanitize(static_page_params[:markdown])
    @preview_html = render_markdown_raw(
      markdown: @new_markdown
    ).html_safe
  end
end
