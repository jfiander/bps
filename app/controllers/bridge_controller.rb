class BridgeController < ApplicationController
  include UserMethods
  include ApplicationHelper
  include BridgeHelper

  before_action :authenticate_user!, except: [:list]
  before_action except: [:list] { require_permission(:users) }
  skip_before_action :verify_authenticity_token, only: %i[auto_show auto_hide]

  skip_before_action :prerender_for_layout, only: %i[
    remove_committee remove_standing_committee
  ]

  before_action :get_users_for_select, only: %i[assign_bridge assign_committee]

  def list
    @current_user_permitted_users = current_user&.permitted?(:users)

    preload_user_data
    bridge_selectors
    build_bridge_list
  end

  def assign_bridge
    bridge_office = BridgeOffice.find_or_create_by(
      office: clean_params[:bridge_office]
    )
    if bridge_office.update(user_id: clean_params[:user_id])
      redirect_to bridge_path, success: "Successfully assigned to bridge office."
    else
      redirect_to bridge_path, alert: "Unable to assign to bridge office."
    end
  end

  def assign_committee
    committee = Committee.create(
      name: clean_params[:committee],
      department: clean_params[:department],
      user_id: clean_params[:user_id]
    )
    if committee.valid?
      redirect_to bridge_path, success: "Successfully assigned to committee."
    else
      redirect_to bridge_path, alert: "Unable to assign to committee."
    end
  end

  def remove_committee(type = :general)
    prep_for_committee_removal(type)
    if @klass.find_by(id: clean_params[:id])&.destroy
      flash[:success] = "Successfully removed#{@standing} committee assignment."
      @do_remove = true
    else
      flash[:alert] = "Unable to remove from#{@standing} committee."
      @do_remove = false
      render status: :unprocessable_entity
    end
  end

  def assign_standing_committee
    y = clean_params[:term_start_at]["(1i)"]
    m = clean_params[:term_start_at]["(2i)"]
    d = clean_params[:term_start_at]["(3i)"]
    term_start = "#{y}-#{m}-#{d}"
    standing_committee = StandingCommitteeOffice.new(
      committee_name: clean_params[:committee_name],
      chair: clean_params[:chair],
      user_id: clean_params[:user_id],
      term_start_at: term_start,
      term_length: clean_params[:term_length]
    )
    if standing_committee.save
      redirect_to bridge_path, success: "Successfully assigned to standing committee."
    else
      redirect_to bridge_path, alert: "Unable to assign to standing committee."
    end
  end

  def remove_standing_committee
    remove_committee(:standing)
  end

  private

  def prep_for_committee_removal(type = :general)
    if type == :general
      @committee_id = clean_params[:id]
      @standing = ''
      @klass = Committee
    elsif type == :standing
      @standing_committee_id = clean_params[:id]
      @standing = ' standing'
      @klass = StandingCommitteeOffice
    end
  end
end
