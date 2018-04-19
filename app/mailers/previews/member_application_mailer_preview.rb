# Preview all emails at http://localhost:3000/rails/mailers/member_application
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

  private

  def application
    MemberApplication.last
  end

  def large_application
    MemberApplication.all.select { |m| m.member_applicants.count > 2 }.last
  end
end
