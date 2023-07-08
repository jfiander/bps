# frozen_string_literal: true

module Admin
  class EmailsController < ::ApplicationController
    secure!(:admin)

    def new
      @users = User.unlocked.alphabetized.where.not(phone_c: nil).map { |u| [u.full_name, u.id] }
    end

    def create
      if (user = User.find_by(id: email_params[:user_id]))
        GenericMailer.generic_message(user, email_params[:message]).deliver
        redirect_to(new_admin_email_path, success: 'Successfully sent email.')
      else
        redirect_to(new_admin_email_path, alert: 'Unable to find that user.')
      end
    end

  private

    def email_params
      params.permit(:user_id, :message)
    end
  end
end
