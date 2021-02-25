# frozen_string_literal: true

module OTWTrainings
  module User
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

    def user_progress
      requirements_path = Rails.root.join('config/boc_requirements.json')
      @boc_requirements = JSON.parse(File.read(requirements_path)).deep_symbolize_keys!
      @completions = pick_user.completions
    end

  private

    def otw_user_params
      params.permit(:id)
    end

    def pick_user
      @user = ::User.find_by(id: otw_user_params[:id]) || current_user
    end

    def levels
      @levels = {
        inland: 'BOC_IN',
        coastal: 'BOC_CN',
        advanced_coastal: 'BOC_ACN',
        offshore: 'BOC_ON'
      }
    end

    def icons
      @icons = {
        'Course' => FA::Icon.p('users-class', style: :duotone, title: 'Course'),
        'Seminar' => FA::Icon.p('presentation', style: :duotone, title: 'Seminar'),
        'Skill' => FA::Icon.p('ship', style: :duotone, title: 'Skill')
      }
    end
  end
end
