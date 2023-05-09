# frozen_string_literal: true

# A set of possible options for a given event, to be chosen from at registration
class EventSelection < ApplicationRecord
  belongs_to :event
  has_many :event_options
end
