# frozen_string_literal: true

class GenericMailerPreview < ApplicationMailerPreview
  def generic_message
    GenericMailer.generic_message(User.first, 'This is a test generic email.')
  end
end
