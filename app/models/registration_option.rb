# frozen_string_literal: true

class RegistrationOption < ApplicationRecord
  belongs_to :registration
  belongs_to :event_option

  delegate :name, to: :event_selection

  validate :option_can_be_selected

private

  def option_can_be_selected
    return if event_option.event_selection.event == registration.event

    errors.add(:base, 'event selection mismatch')
  end
end
