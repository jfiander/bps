# frozen_string_literal: true

class OTWMailerPreview < ActionMailer::Preview
  def requested
    OTWMailer.requested(OTWTrainingUser.last)
  end
end
