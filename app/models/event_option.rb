# frozen_string_literal: true

# A single possible option out of a selection, to be chosen at registration
class EventOption < ApplicationRecord
  belongs_to :event_selection
end
