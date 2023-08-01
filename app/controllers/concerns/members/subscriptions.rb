# frozen_string_literal: true

module Members
  module Subscriptions
    def subscribe
      raise 'No topic ARN found' if registration.event.topic_arn.blank?
      raise 'No cell phone' if mobile_phone(registration.user).blank?

      registration.update(subscription_arn: new_subscription(registration))
    end

    def unsubscribe
      BPS::SMS.unsubscribe(registration.subscription_arn)
      registration.update(subscription_arn: nil)

      render :subscribe
    end

  private

    def subscriptions_params
      params.permit(:id)
    end

    def registration
      @registration ||= Registration.find_by(id: subscriptions_params[:id])
    end

    def require_registered_user
      return if registration.user == current_user

      redirect_to(profile_path, alert: 'You are not authorized to modify that.')
    end

    def new_subscription(registration)
      BPS::SMS.subscribe(
        registration.event.topic_arn,
        mobile_phone(registration.user)
      ).subscription_arn
    end

    def mobile_phone(user)
      user.phone_c_preferred.presence || user.phone_c
    end
  end
end
