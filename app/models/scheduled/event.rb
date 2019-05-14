# frozen_string_literal: true

class Scheduled::Event < Scheduled::Base
  def self.include_details
    includes(:event_type)
  end

  def self.for_category(_ignored = nil)
    category = 'meeting'
    includes(:event_type).where(event_types: { event_category: category })
  end
end
