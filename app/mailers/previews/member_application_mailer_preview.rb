# frozen_string_literal: true

class MemberApplicationPreview < ActionMailer::Preview
  def new_application
    MemberApplicationMailer.new_application(application)
  end

  def confirm
    MemberApplicationMailer.confirm(application)
  end

  def approved
    MemberApplicationMailer.approved(application)
  end

  def approved_three
    MemberApplicationMailer.approved(large_application)
  end

  def approval_notice
    MemberApplicationMailer.approval_notice(application)
  end

  def paid
    MemberApplicationMailer.paid(application)
  end

  def paid_dues
    MemberApplicationMailer.paid_dues(user)
  end

private

  def application
    @application ||= MemberApplication.new
    @application.member_applicants << applicant(@application)
    @application.payment = Payment.new
    @application
  end

  def large_application
    @large_application ||= MemberApplication.new
    @large_application.member_applicants << applicants(@large_application)
    @large_application
  end

  def applicant(application)
    @applicant ||= MemberApplicant.new(member_application: application, primary: true, member_type: 'Active', boat_type: 'None')
  end

  def applicants(application)
    @applicants ||= [
      MemberApplicant.new(member_application: application, primary: true, member_type: 'Active', boat_type: 'None'),
      MemberApplicant.new(member_application: application, primary: false, member_type: 'Family'),
      MemberApplicant.new(member_application: application, primary: false, member_type: 'Family')
    ]
  end

  def user
    @user ||= User.new(parent_id: nil)
  end
end
