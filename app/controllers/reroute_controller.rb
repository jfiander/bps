# frozen_string_literal: true

class RerouteController < ApplicationController
  def excom
    redirect_to("https://meet.google.com/#{ENV.fetch('EXCOM_MEET_ID', nil)}")
  end

  def member_meeting
    redirect_to("https://meet.google.com/#{ENV.fetch('MEMBERSHIP_MEET_ID', nil)}")
  end
end
