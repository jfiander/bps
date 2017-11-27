class StaticPage < ApplicationRecord
  def self.names
    all.map(&:name)
  end
end
