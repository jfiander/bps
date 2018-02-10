class StaticPage < ApplicationRecord
  acts_as_paranoid

  def self.names
    all.map(&:name)
  end
end
