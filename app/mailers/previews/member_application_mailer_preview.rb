# Preview all emails at http://localhost:3000/rails/mailers/member_application
class MemberApplicationPreview < ActionMailer::Preview
  def new_application
    MemberApplicationMailer.new_application(application)
  end

  def confirm
    MemberApplicationMailer.confirm(application)
  end

  private

  def application
    MemberApplication.last
  end
end
