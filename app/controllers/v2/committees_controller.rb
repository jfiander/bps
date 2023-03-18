# frozen_string_literal: true

module V2
  class CommitteesController < ApplicationController
    include User::Load
    include ApplicationHelper
    include BridgeHelper
    include Concerns::Application::RedirectWithStatus

    secure!(:users)

    def create
      committee = Committee.new(
        name: clean_params[:committee], department: clean_params[:department],
        user_id: clean_params[:user_id]
      )

      redirect_with_status(bridge_path, object: 'committee', verb: 'assign', past: 'assigned') do
        committee.save
      end
    end

    def destroy
      @committee_id = clean_params[:id]
      if Committee.find_by(id: clean_params[:id])&.destroy
        flash[:success] = 'Successfully removed committee assignment.'
        @do_remove = true
      else
        flash[:alert] = 'Unable to remove from committee.'
        @do_remove = false
        render status: :unprocessable_entity
      end
    end

  private

    def clean_params
      params.permit(:id, :user_id, :committee, :department, :committee_name)
    end

    def missing_committees
      auto_roles = YAML.safe_load(
        Rails.root.join('config/implicit_permissions.yml')
      )['committee'].keys
      @missing_committees = auto_roles - Committee.all.map(&:name)
    end
  end
end
