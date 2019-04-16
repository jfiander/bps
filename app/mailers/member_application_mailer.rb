# frozen_string_literal: true

class MemberApplicationMailer < ApplicationMailer
  include DateHelper
  include MailerSignatures

  def new_application(application)
    @application = application
    @to_list = new_app_to
    @next_excom = next_excom

    mail(to: @to_list, subject: 'New member application')
    new_application_slack_notification
  end

  def confirm(application)
    prep_external(application)

    mail(to: @to, from: @signature[:email], subject: 'Member application received!')
  end

  def approved(application)
    prep_external(application)

    mail(to: @to, from: @signature[:email], subject: 'Member application approved!')
  end

  def approval_notice(application)
    @application = application
    @to_list = new_app_to

    mail(to: @to_list, subject: 'Member application approved')
  end

  def paid(application)
    @application = application
    @to_list = new_app_to

    mail(to: @to_list, subject: 'Membership application paid')
  end

  def paid_dues(user)
    @user = user
    @to_list = BridgeOffice.includes(:user).heads.where(
      office: %w[treasurer administrative]
    ).map(&:user).map(&:email)

    mail(to: @to_list, subject: 'Annual dues paid')
  end

private

  def new_app_to
    [
      BridgeOffice.includes(:user).heads.map(&:user).map(&:email),
      StandingCommitteeOffice.current.where(committee_name: 'executive').map { |c| c&.user&.email }
    ].flatten.uniq.compact
  end

  def prep_external(application)
    @application = application
    @to = @application.primary.email
    @signature = ao_signature
  end

  def new_application_slack_notification
    SlackNotification.new(
      type: :info, title: 'Membership Application Received',
      fallback: 'Someone has applied for membership.',
      fields: new_application_slack_fields(
        "#{@application.primary.first_name} #{@application.primary.last_name}",
        @application.primary.email,
        @application.member_applicants.count,
      )
    )
  end

  def new_application_slack_fields(name, email, number)
    [
      { 'title' => 'Primary applicant name', 'value' => name, 'short' => true },
      { 'title' => 'Primary applicant email', 'value' => email, 'short' => true },
      { 'title' => 'Number of applicants', 'value' => number, 'short' => true }
    ]
  end
end
