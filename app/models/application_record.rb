class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.find_or_create(attributes)
    query = self.find_by(attributes)
    return self.create!(attributes) if query.blank?
    query
  end
end
