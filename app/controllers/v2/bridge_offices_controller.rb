# frozen_string_literal: true

module V2
  class BridgeOfficesController < ApplicationController
    include User::Load
    include ApplicationHelper
    include BridgeHelper
    include Concerns::Application::RedirectWithStatus

    secure!(:users, except: :index)

    title!('Officers')

    before_action :users_for_select, only: %i[update]
    before_action :permitted_users, only: %i[index]
    before_action :find_bridge_office, only: %i[update]

    def index
      missing_committees if @current_user_permitted_users

      preload_user_data
      bridge_selectors
      build_bridge_list
    end

    def update
      previous = @bridge_office.user

      redirect_with_status(
        bridge_path, object: 'bridge office', verb: 'assign', past: 'assigned'
      ) do
        @bridge_office.update(user_id: clean_params[:user_id])
        NotificationsMailer.bridge(
          @bridge_office, by: current_user, previous: previous
        ).deliver
      end
    end

  private

    def clean_params
      params.permit(:id, :user_id, :bridge_office)
    end

    def permitted_users
      @current_user_permitted_users = current_user&.permitted?(:users)
    end

    def find_bridge_office
      @bridge_office = BridgeOffice.find_or_create_by(
        office: clean_params[:bridge_office]
      )
    end
  end
end
