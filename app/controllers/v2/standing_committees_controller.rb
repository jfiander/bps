# frozen_string_literal: true

module V2
  class StandingCommitteesController < ApplicationController
    include User::Load
    include ApplicationHelper
    include BridgeHelper
    include Concerns::Application::RedirectWithStatus

    secure!(:users)

    def create
      standing_committee = create_standing_committee

      redirect_with_status(
        bridge_path, object: 'standing committee', verb: 'assign', past: 'assigned'
      ) do
        standing_committee.save
      end
    end

    def destroy
      @standing_committee_id = clean_params[:id]
      if StandingCommitteeOffice.find_by(id: clean_params[:id])&.destroy
        flash[:success] = 'Successfully removed standing committee assignment.'
        @do_remove = true
      else
        flash[:alert] = 'Unable to remove from standing committee.'
        @do_remove = false
        render status: :unprocessable_entity
      end
    end

  private

    def clean_params
      params.permit(
        :id, :user_id, :committee_name, :chair,
        :term_length, term_start_at: ['(1i)', '(2i)', '(3i)']
      )
    end

    def missing_committees
      auto_roles = YAML.safe_load(
        Rails.root.join('config/implicit_permissions.yml')
      )['committee'].keys
      @missing_committees = auto_roles - Committee.all.map(&:name)
    end

    def create_standing_committee
      StandingCommitteeOffice.new(
        committee_name: clean_params[:committee_name],
        chair: clean_params[:chair],
        user_id: clean_params[:user_id],
        term_start_at: standing_committee_term_start_at,
        term_length: clean_params[:term_length]
      )
    end

    def standing_committee_term_start_at
      y = clean_params[:term_start_at]['(1i)']
      m = clean_params[:term_start_at]['(2i)']
      d = clean_params[:term_start_at]['(3i)']

      "#{y}-#{m}-#{d}"
    end
  end
end
