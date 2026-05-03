# frozen_string_literal: true

class RerouteController < ApplicationController
  def excom
    redirect_to("https://meet.google.com/#{ENV['EXCOM_MEET_ID']}", allow_other_host: true)
  end

  def member_meeting
    redirect_to("https://meet.google.com/#{ENV['MEMBERSHIP_MEET_ID']}", allow_other_host: true)
  end
end
