class UserMailer < Devise::Mailer
  helper :application
  helper ScssHelper
  include Devise::Controllers::UrlHelpers
  default from: '"BPS Support" <support@bpsd9.org>'
  default template_path: 'devise/mailer'
  layout 'mailer'
end
