# frozen_string_literal: true

module Users
  class RegistrationsController < ::Devise::RegistrationsController
    include Application::Security

    secure!(:admin, strict: true, only: %i[admin_edit admin_update])

    def admin_edit
      self.resource = @user = User.find_by(id: params[:id])
      render :edit
    end

    def admin_update
      self.resource = User.find_by(id: params[:id])

      # Manually update rank_override
      update_rank_override

      # Modified from Devise RegistrationsController#update
      resource_updated = update_resource(resource, account_update_params)
      set_flash_message_for_update(resource, prev_unconfirmed_email) if resource_updated

      redirect_to(user_path(resource))
    end

    def after_update_path_for(_resource)
      profile_path
    end

  private

    def update_rank_override
      return unless current_user.permitted?(:admin, strict: true)

      resource.update(rank_override: params[:user][:rank_override])
    end
  end
end
