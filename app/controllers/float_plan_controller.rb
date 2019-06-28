# frozen_string_literal: true

class FloatPlanController < ApplicationController
  secure!
  secure!(:float, only: %i[list refresh])

  title!('Float Plans')

  after_action :slack_notification, only: :submit

  def new
    @last = FloatPlan.where(user_id: current_user&.id)&.last
    non_persisted = %w[id leave_at return_at alert_at]
    @float_plan = FloatPlan.new(@last&.attributes&.except(*non_persisted))
  end

  def submit
    @float_plan = FloatPlan.new(float_plan_params.merge(user_id: current_user&.id))
    onboards = float_plan_params[:float_plan_onboards_attributes]
    return no_onboards if onboards.blank?

    append_problem_timestamps
    @float_plan.save!
  end

  def refresh
    float_plan = FloatPlan.find_by(id: refresh_params[:id])
    verb = float_plan.pdf.exists? ? 'Refreshed' : 'Generated'
    float_plan.generate_pdf
    flash[:success] = "#{verb} float plan ##{float_plan.id}"
    redirect_to float_plans_path
  end

  def list
    @float_plans = FloatPlan.includes(:float_plan_onboards).all
  end

private

  def float_plan_params
    params.permit(
      float_plan: core_float_plan_params << {
        float_plan_onboards_attributes: %i[name age address phone _destroy]
      }
    )[:float_plan]
  end

  def core_float_plan_params
    %i[
      name phone boat_type subtype hull_color trim_color deck_color sail_color registration_number
      hin length boat_name make model year engine_type_1 engine_type_2 horse_power number_of_engines
      fuel_capacity pfds flares mirror horn smoke flashlight raft epirb paddles food water anchor
      epirb_16 epirb_1215 epirb_406 radio radio_vhf radio_ssb radio_cb radio_cell_phone
      channels_monitored call_sign leave_from going_to leave_at return_at alert_at comments
      car_make car_model car_year car_color car_license_plate
      trailer_license_plate car_parked_at alert_name alert_phone
    ]
  end

  def refresh_params
    params.permit(:id)
  end

  def slack_notification
    return unless @float_plan.persisted?

    NotificationsMailer.float_plan(@float_plan).deliver
    SlackNotification.new(
      channel: 'floatplans', type: :info, title: 'Float Plan Submitted',
      fallback: 'Someone has submitted a float plan.',
      fields: slack_fields
    ).notify!
  end

  def slack_fields
    [
      slack_by_field,
      { title: 'Contact Name', value: @float_plan.name, short: true },
      { title: 'Contact Phone', value: @float_plan.phone, short: true },
      { title: 'Depart', value: format_fp_time(:leave_at), short: true },
      { title: 'Return', value: format_fp_time(:return_at), short: true },
      { title: 'Alert', value: format_fp_time(:alert_at), short: true },
      { title: 'Float Plan PDF', value: @float_plan.link, short: false }
    ].compact
  end

  def slack_by_field
    return unless @float_plan.user.present?

    { title: 'Submitted by', value: @float_plan.user.full_name, short: false }
  end

  def format_fp_time(method)
    @float_plan.send(method)&.strftime(ApplicationController::LONG_TIME_FORMAT)
  end

  def no_onboards
    flash.now[:alert] = 'You must include who will be onboard.'
    render :new
  end

  def append_to_comments(text)
    @float_plan.update(comments: @float_plan.comments + "\n #{text}")
  end

  def append_problem_timestamps
    %i[leave_at return_at alert_at].each do |method|
      next if @float_plan.send(method)

      append_to_comments("#{method.to_s.titleize}: #{float_plan_params[method]}")
    end
  end
end
