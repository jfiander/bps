# frozen_string_literal: true

class OTWMailerPreview < ApplicationMailerPreview
  def requested
    OTWMailer.requested(OTWTrainingUser.new(otw_training: OTWTraining.new, user: user))
  end

  def jumpstart
    OTWMailer.jumpstart(
      name: 'John Q Public',
      email: 'nobody@example.com',
      phone: '555-555-5555',
      details: 'Some boat details',
      availability: 'Whenever'
    )
  end

  def jumpstart_only_availability
    OTWMailer.jumpstart(
      name: 'John Q Public',
      email: 'nobody@example.com',
      availability: 'Whenever'
    )
  end
end
