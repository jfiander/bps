# frozen_string_literal: true

class EventInstructor < ApplicationRecord
  belongs_to :user
  belongs_to :event
end
