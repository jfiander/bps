class MemberApplicationMailer < ApplicationMailer
  include DateHelper

  def new_application(application)
    @application = application
    @to_list = new_app_to
    @next_excom = next_excom

    mail(to: @to_list, subject: 'New member application')
  end

  def confirm(application)
    prep_external(application)

    mail(to: @to, subject: 'Member application received!')
  end

  def approved(application)
    prep_external(application)

    mail(to: @to, subject: 'Member application approved!')
  end

  def approval_notice(application)
    @application = application
    @to_list = new_app_to

    mail(to: @to_list, subject: 'Member application approved')
  end

  private

  def new_app_to
    [
      BridgeOffice.includes(:user).heads.map(&:user).map(&:email),
      StandingCommitteeOffice.current.where(committee_name: 'executive')
                             .map(&:user).map(&:email)
    ].flatten.uniq
  end

  def prep_external(application)
    @application = application
    @to = @application.primary.email
    ao = BridgeOffice.includes(:user).find_by(office: 'administrative')
    @signature = {
      office: ao.office.titleize,
      email: ao.email,
      name: ao.user.full_name
    }
  end
end
