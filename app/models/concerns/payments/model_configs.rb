# frozen_string_literal: true

# Configuration for payable models
module Payments::ModelConfigs
  extend ActiveSupport::Concern

  def purchase_info
    case parent_type
    when 'Registration'
      type = parent.type
      type = nil unless type.in?(displayable_registration_types)
      registration_info(type)
    when 'MemberApplication'
      member_application_info
    when 'User'
      dues_info
    end
  end

  def purchase_subject
    case parent_type
    when 'Registration'
      "#{parent.event.event_type.display_title} on " \
      "#{parent.event.start_at.strftime(ApplicationController::SHORT_TIME_FORMAT)}"
    when 'MemberApplication'
      'Membership application'
    when 'User'
      'Annual dues'
    end
  end

  private

  def displayable_registration_types
    %w[course seminar]
  end

  def registration_info(type = nil)
    {
      name: parent.event.event_type.display_title,
      type: type,
      date: parent.event.start_at.strftime(ApplicationController::PUBLIC_DATE_FORMAT),
      time: parent.event.start_at.strftime(ApplicationController::PUBLIC_TIME_FORMAT)
    }
  end

  def member_application_info
    { name: 'Membership application', people: parent.member_applicants.count }
  end

  def dues_info
    { name: 'Annual dues', people: parent.children.count }
  end
end
