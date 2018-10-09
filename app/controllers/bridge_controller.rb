# frozen_string_literal: true

class BridgeController < ApplicationController
  include User::Load
  include ApplicationHelper
  include BridgeHelper
  include Concerns::Application::RedirectWithStatus

  secure!(:users, except: :list)

  title!('Officers')

  before_action :users_for_select, only: %i[assign_bridge assign_committee]

  def list
    @current_user_permitted_users = current_user&.permitted?(:users, session: session)

    preload_user_data
    bridge_selectors
    build_bridge_list
  end

  def assign_bridge
    bridge_office = BridgeOffice.find_or_create_by(
      office: clean_params[:bridge_office]
    )
    previous = bridge_office.user

    redirect_with_status(bridge_path, object: 'bridge office', verb: 'assign', past: 'assigned') do
      bridge_office.update(user_id: clean_params[:user_id])
      NotificationsMailer.bridge(bridge_office, by: current_user, previous: previous).deliver
    end
  end

  def assign_committee
    committee = Committee.new(
      name: clean_params[:committee],
      department: clean_params[:department],
      user_id: clean_params[:user_id]
    )

    redirect_with_status(bridge_path, object: 'committee', verb: 'assign', past: 'assigned') do
      committee.save
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
    y = clean_params[:term_start_at]['(1i)']
    m = clean_params[:term_start_at]['(2i)']
    d = clean_params[:term_start_at]['(3i)']
    term_start = "#{y}-#{m}-#{d}"
    standing_committee = StandingCommitteeOffice.new(
      committee_name: clean_params[:committee_name],
      chair: clean_params[:chair],
      user_id: clean_params[:user_id],
      term_start_at: term_start,
      term_length: clean_params[:term_length]
    )

    redirect_with_status(bridge_path, object: 'standing committee', verb: 'assign', past: 'assigned') do
      standing_committee.save
    end
  end

  def remove_standing_committee
    remove_committee(:standing)
  end

  private

  def clean_params
    params.permit(
      :id, :user_id, :bridge_office, :committee, :department, :committee_name,
      :chair, :term_length, term_start_at: ['(1i)', '(2i)', '(3i)']
    )
  end

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
