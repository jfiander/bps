# frozen_string_literal: true

class MembersController < ApplicationController
  include Members::Bilge
  include Members::Minutes
  include Members::Roster
  include Members::Markdown
  include Members::Dues
  include Members::Store
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

  before_action :list_minutes, only: %i[minutes find_minutes find_minutes_excom]

  before_action :generate_client_token, only: :applied
  before_action :block_duplicate_payments, only: :applied, if: :already_paid?

  title!('Minutes', only: :minutes)
  title!('ExCom Minutes', only: :excom_minutes)
  title!('Edit Page', only: :edit_markdown)
  title!('Member Ranks and Grades', only: :ranks)
  title!('Automatic Permissions', only: :auto_permits)

  render_markdown_views

  def ranks
    @users = User.unlocked.include_positions.alphabetized.with_any_name
  end

  private

  def static_page_params
    params.require(:static_page).permit(:name, :markdown)
  end

  def clean_params
    params.permit(:page_name, :id, :save, :preview)
  end

  def update_file(model)
    if send("#{model}_params")["#{model}_remove".to_sym].present?
      send("remove_#{model}")
      'removed'
    elsif (file = send("find_#{model}_issue")).present?
      file.update(file: send("#{model}_params")[:file])
      'replaced'
    else
      send("create_#{model}")
      'uplodaed'
    end
  end
end
