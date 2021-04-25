# frozen_string_literal: true

class EventTypeCommittee < ApplicationRecord
  belongs_to :event_type

  def committees
    @committees ||= Committee.where(name: committee)
  end

  def dept_heads
    departments = committees.map(&:department).uniq
    BridgeOffice.where(office: departments)
  end
end
