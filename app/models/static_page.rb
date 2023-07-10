# frozen_string_literal: true

class StaticPage < ApplicationRecord
  CUSTOM_TITLES = {
    'about' => 'About Us',
    'join' => 'Join Us',
    'civic' => 'Civic Services',
    'vsc' => 'Vessel Safety Check'
  }.freeze

  def self.names
    all.map(&:name)
  end

  def title
    CUSTOM_TITLES[name] || name.titleize
  end
end
