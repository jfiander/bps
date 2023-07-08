# frozen_string_literal: true

class GenericMailer < ApplicationMailer
  def generic_message(user, message)
    @to_list = [user.email]
    @message = message

    mail(to: @to_list, subject: "A Message from America's Boating Club - Birmingham Squadron")
  end
end
