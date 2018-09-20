# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  helper ScssHelper
  helper DateHelper
  default from: '"BPS Support" <support@bpsd9.org>'
  layout 'mailer'
end
