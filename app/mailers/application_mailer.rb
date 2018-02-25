class ApplicationMailer < ActionMailer::Base
  helper ScssHelper
  default from: '"BPS Support" <support@bpsd9.org>'
  layout 'mailer'
end
