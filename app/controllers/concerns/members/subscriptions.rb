# frozen_string_literal: true

module Members
  module Subscriptions
    def subscribe
      raise 'No topic ARN found' if registration.event.topic_arn.blank?
      raise 'No cell phone' if registration.user.phone_c.blank?

      registration.update(subscription_arn: new_subscription(registration))
    end

    def unsubscribe
      BpsSMS.unsubscribe(registration.subscription_arn)
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
      BpsSMS.subscribe(registration.event.topic_arn, registration.user.phone_c).subscription_arn
    end
  end
end
