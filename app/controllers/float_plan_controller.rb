# frozen_string_literal: true

class FloatPlanController < ApplicationController
  secure!
  secure!(:float, only: %i[list refresh])

  title!('Float Plans')

  def new
    @float_plan = FloatPlan.new
  end

  def submit
    @float_plan = FloatPlan.new(float_plan_params)
    onboards = float_plan_params[:float_plan_onboards_attributes]
    if onboards.blank?
      flash.now[:alert] = 'You must include who will be onboard.'
      render :new
      return
    end

    @float_plan.save!

    slack_notification
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
      float_plan: %i[
        name phone boat_type subtype hull_color trim_color registration_number
        length boat_name make model year engine_type_1 engine_type_2 horse_power
        number_of_engines fuel_capacity pfds flares mirror horn smoke flashlight
        raft epirb paddles food water anchor epirb_16 epirb_1215 epirb_406 radio
        radio_vhf radio_ssb radio_cb radio_cell_phone channels_monitored
        call_sign leave_from going_to leave_at return_at alert_at comments
        car_make car_model car_year car_color car_license_plate
        trailer_license_plate car_parked_at alert_name alert_phone
      ] <<
      { float_plan_onboards_attributes: %i[name age address phone _destroy] }
    )[:float_plan]
  end

  def refresh_params
    params.permit(:id)
  end

  def slack_notification
    NotificationsMailer.float_plan(@float_plan).deliver
    SlackNotification.new(
      channel: 'floatplans', type: :info, title: 'Float Plan Submitted',
      fallback: 'Someone has submitted a float plan.',
      fields: [
        { title: 'Name', value: @float_plan.name, short: true },
        { title: 'Phone', value: @float_plan.phone, short: true },
        {
          title: 'Depart',
          value: @float_plan.leave_at.strftime(@long_time_format),
          short: true
        },
        {
          title: 'Return',
          value: @float_plan.return_at.strftime(@long_time_format),
          short: true
        },
        {
          title: 'Alert',
          value: @float_plan.alert_at.strftime(@long_time_format),
          short: true
        },
        { title: 'Float Plan PDF', value: @float_plan.link, short: false }
      ]
    ).notify!
  end
end
