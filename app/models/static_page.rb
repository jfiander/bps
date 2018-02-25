class StaticPage < ApplicationRecord
  def self.names
    all.map(&:name)
  end

  def title
    case name
    when 'about'
      'About Us'
    when 'join'
      'Join Us'
    when 'civic'
      'Civic Services'
    when 'vsc'
      'Vessel Safety Check'
    else
      name.titleize
    end
  end
end
