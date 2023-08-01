# frozen_string_literal: true

module Admin
  class MessagesController < ::ApplicationController
    secure!(:admin)

    def new
      @users = User.unlocked.alphabetized.where.not(phone_c: nil).map { |u| [u.full_name, u.id] }
    end

    def create
      if (user = User.find_by(id: sms_params[:user_id]))
        BPS::SMS.publish(mobile_phone(user), sms_params[:message])
        redirect_to(new_admin_message_path, success: 'Successfully sent message.')
      else
        redirect_to(new_admin_message_path, alert: 'Unable to find that user.')
      end
    end

  private

    def sms_params
      params.permit(:user_id, :message)
    end

    def mobile_phone(user)
      user.phone_c_preferred.presence || user.phone_c
    end
  end
end
