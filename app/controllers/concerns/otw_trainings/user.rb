# frozen_string_literal: true

module OTWTrainings::User
  def user
    @otw_requests = current_user&.otw_trainings&.where(
      'otw_training_users.created_at > ?', Date.today - 6.months
    )
    @otw_credits = @otw_trainings.select { |o| o.course_key.in?(current_user.completions.keys) }
  end

  def user_request
    @otw = OTWTraining.find_by(id: otw_user_params[:id])

    if (otw_request = OTWTrainingUser.find_or_create_by(otw_training: @otw, user: current_user))
      user_request_succeeded(otw_request)
    else
      user_request_failed(otw_request)
    end
  end

private

  def otw_user_params
    params.permit(:id)
  end
end
