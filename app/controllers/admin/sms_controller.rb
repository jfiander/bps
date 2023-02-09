# frozen_string_literal: true

module Admin
  class SmsController < ::ApplicationController
    def new
      @users = User.unlocked.alphabetized.where.not(phone_c: nil).map { |u| [u.full_name, u.id] }
    end

    def send_message
      if (user = User.find_by(id: sms_params[:user_id]))
        BPS::SMS.publish(user.phone_c, sms_params[:message])
        redirect_to(admin_message_path, success: 'Successfully sent message.')
      else
        redirect_to(admin_message_path, alert: 'Unable to find that user.')
      end
    end

  private

    def sms_params
      params.permit(:user_id, :message)
    end
  end
end
