# frozen_string_literal: true

class MembersController < ApplicationController
  include Members::Bilge
  include Members::Announcements
  include Members::Minutes
  include Members::Roster
  include Members::Markdown
  include Members::Dues
  include Members::Nominations
  include Members::Subscriptions
  include BraintreeHelper

  secure!
  secure!(:admin, only: :admin)
  secure!(:newsletter, only: %i[upload_bilge upload_announcement remove_announcement])
  secure!(:minutes, only: :upload_minutes)
  secure!(:roster, only: %i[update_roster upload_roster])
  secure!(:page, only: %i[edit_markdown update_markdown])
  secure!(%i[users newsletter page minutes event education], only: %i[ranks])

  before_action :redirect_to_root, only: :dues, unless: :braintree_enabled?
  before_action :prepare_dues, only: :dues, if: :current_user_dues_due?

  before_action :list_minutes, only: %i[minutes find_minutes find_minutes_excom]

  before_action :generate_client_token, only: :applied
  before_action :block_duplicate_payments, only: :applied, if: :already_paid?
  before_action :redirect_if_no_roster, only: :roster
  before_action :reject_invalid_file, only: :upload_roster

  before_action :require_registered_user, only: %i[subscribe_registration unsubscribe_registration]

  title!('Minutes', only: :minutes)
  title!('ExCom Minutes', only: :excom_minutes)
  title!('Edit Page', only: :edit_markdown)
  title!('Member Ranks and Grades', only: :ranks)
  title!('Automatic Permissions', only: :auto_permits)

  render_markdown_views

  def ranks
    @users = User.unlocked.include_positions.alphabetized.with_any_name
  end

  def vse
    @users = User.alphabetized.unlocked.includes(:course_completions).select do |u|
      u.course_completions.any? { |c| c.course_key == 'VSC_01' }
    end
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
      replace_file(model, file)
    else
      send("create_#{model}")
      'uploaded'
    end
  end

  def replace_file(model, file)
    file.update(file: send("#{model}_params")[:file])
    # send("invalidate_#{model}", file)
    'replaced'
  end
end
