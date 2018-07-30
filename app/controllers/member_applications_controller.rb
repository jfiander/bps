# frozen_string_literal: true

class MemberApplicationsController < ApplicationController
  secure!(only: :review)

  def new
    @member_application = MemberApplication.new
    @member_application_person = MemberApplicant.new(
      member_application: @member_application
    )

    @member_application_persons = [@member_application_person]
  end

  def apply
    if process_application
      # When Braintree is available:
      # ask = ask_to_pay_path(
      #   model: member_application,
      #   id: member_application.id
      # )
      # render js: "window.location = '#{ask}'"
      confirm_applied_path = applied_path(id: @member_application.id)
      MemberApplicationMailer.new_application(@member_application).deliver
      MemberApplicationMailer.confirm(@member_application).deliver
      render js: "window.location = '#{confirm_applied_path}'"
    else
      flash.now[:alert] = 'There was a problem with your application.'
    end
  end

  def applied
    @member_application = MemberApplication.find_by(id: applied_params[:id])
  end

  def review
    @applications = MemberApplication.pending
  end

  def approve
    @member_application = MemberApplication.find_by(id: applied_params[:id])

    if @member_application.approve!(current_user) == { requires: :excom }
      flash.now[:alert] = 'Only ExCom members can approve applications.'
      render 'applicaiton/update_flashes'
    end

    flash.now[:success] = 'Successfully approved application and invited new members!'
  end

  private

  def primary_member_params
    params.permit(
      %i[
        first_name middle_name last_name dob gender
        address_1 address_2 city state zip email phone_h phone_c phone_w fax
        boat_type boat_length boat_name sig_other_name previous_certificate
      ]
    )
  end

  def additional_member_params
    params.permit(
      member_application: {
        member_applicants_attributes: %i[
          primary first_name middle_name last_name dob gender
          address_1 address_2 city state zip phone_h phone_c
          phone_w fax email sea_scout sig_other_name boat_type
          boat_length boat_name previous_certificate _destroy
        ]
      }
    )
  end

  def applied_params
    params.permit(:id)
  end

  def process_application
    MemberApplication.transaction do
      begin
        @member_application = MemberApplication.new
        @member_application_persons = []
        save_application
        return true
      rescue ActiveRecord::RecordInvalid => e
        flash.now[:error] = e.message.gsub('Member applicants base ', '')
                             .gsub('Validation failed: ', '') # Validation error flashes are not displaying
        raise ActiveRecord::Rollback
      end
    end
    false
  end

  def save_application
    @member_application = MemberApplication.create!(applicants)
  end

  def applicants
    primary = primary_member_params.to_h.merge(
      primary: true, member_application: @member_application
    )
    apps = additional_member_params.values.map(&:to_h).map(&:values).flatten

    apps = apps.map(&:values).flatten.reject do |a|
      a == true ||
        a.is_a?(MemberApplication) ||
        a.key?('_destroy')
    end

    apps.each do |a|
      a[:member_application] = @member_application
      a[:primary] = false
    end

    all_apps = [primary, apps].flatten
    return if all_apps.blank?

    { 'member_applicants_attributes' => all_apps }
  end
end
