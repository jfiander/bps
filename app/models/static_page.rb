# frozen_string_literal: true

class StaticPage < ApplicationRecord
  CUSTOM_TITLES = {
    'about' => 'About Us',
    'join' => 'Join Us',
    'civic' => 'Civic Services',
    'vsc' => 'Vessel Safety Check'
  }.freeze

  class << self
    def names
      @names ||= all.map(&:name)
    end
  end

  def title
    CUSTOM_TITLES[name] || name.titleize
  end
end
