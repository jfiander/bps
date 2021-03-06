# frozen_string_literal: true

class MemberApplicationsController < ApplicationController
  include BraintreeHelper

  secure!(:excom, only: %i[review approve])

  title!('Become a Member!')

  before_action :load_payment, only: :applied
  before_action :process_application, only: :apply

  def new
    @member_application = MemberApplication.new
    @member_application_person = MemberApplicant.new(
      member_application: @member_application
    )

    @member_application_persons = [@member_application_person]
  end

  def apply
    if @member_application.persisted?
      confirm_applied_path = applied_path(
        token: @member_application.payment.token
      )
      MemberApplicationMailer.confirm(@member_application).deliver
      render js: "window.location = '#{confirm_applied_path}'"
    else
      flash.now[:alert] = 'There was a problem with your application.'
    end
  end

  def applied
    transaction_details
    @purchase_info[:registered] = @payment.parent.member_applicants

    @client_token = Payment.client_token(user_id: current_user&.id)
    @receipt = @payment.parent.primary.email
    @address = BridgeOffice.includes(:user).find_by(office: :treasurer).user.mailing_address
  end

  def review
    @applications = MemberApplication.pending
  end

  def approve
    @member_application = MemberApplication.find_by(id: approve_params[:id])

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
    params.permit(:token)
  end

  def approve_params
    params.permit(:id)
  end

  def load_payment
    @token = applied_params[:token]
    @payment = Payment.find_by(token: @token)
  end

  def process_application
    MemberApplication.transaction do
      create_application
    end
  rescue ActiveRecord::RecordInvalid => e
    failed_application(e)
  end

  def create_application
    @member_application = MemberApplication.new
    people = applicants['member_applicants_attributes'].first.map do |a|
      person = MemberApplicant.new(a.merge(member_application: @member_application))
      @member_application.member_applicants << person
    end
    @member_application_persons = [people]

    @member_application.save!
  end

  def failed_application(e)
    flash.now[:error] = e.message.gsub('Member applicants base ', '')
                         .gsub('Validation failed: ', '')
  end

  def applicants
    return applicant_attributes_hash([primary_applicant]) if additionals.blank?

    applicant_attributes_hash(with_additionals)
  end

  def applicant_attributes_hash(*applicants)
    { 'member_applicants_attributes' => applicants }
  end

  def primary_applicant
    primary_member_params.to_h.merge(
      primary: true, member_application: @member_application
    )
  end

  def with_additionals
    adds = additionals.reduce({}, :merge).values.reject do |a|
      a == true || a.is_a?(MemberApplication) || a.key?('_destroy')
    end

    adds.each do |a|
      a[:member_application] = @member_application
      a[:primary] = false
    end

    [primary_applicant, adds].compact.flatten
  end

  def additionals
    @additionals ||= additional_member_params.values.map(&:to_h).map(&:values).flatten
  end
end
