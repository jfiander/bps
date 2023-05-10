# frozen_string_literal: true

class RegistrationOption < ApplicationRecord
  belongs_to :registration
  belongs_to :event_option

  validate :option_can_be_selected

  delegate :name, to: :event_option

  def description
    event_option.event_selection.description
  end

private

  def option_can_be_selected
    return if event_option.event_selection.event == registration.event

    errors.add(:base, 'event selection mismatch')
  end
end
