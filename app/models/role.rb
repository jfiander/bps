# frozen_string_literal: true

class Role < ApplicationRecord
  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles
  belongs_to :parent, class_name: 'Role', optional: true
  has_many :children, class_name: 'Role', foreign_key: :parent_id, inverse_of: :parent

  before_validation :set_nil_parent_to_admin

  validate :descends_from_admin?
  validate :admin_no_parent_id
  validates :name, uniqueness: true

  def self.icons
    regular = all.each_with_object({}) { |role, hash| hash[role.name.to_sym] = role.icon }
    regular.merge(all: 'globe', excom: 'chevron-circle-down')
  end

  def self.recursive_lookup(*searches)
    recursive_search(*searches, direction: :up)
  end

  def self.recursive_lookdown(*searches)
    recursive_search(*searches, direction: :down)
  end

  def self.recursive_search(*searches, direction: :up)
    clean_searches = searches.flatten.compact_blank
    return [] if clean_searches.blank?

    Rails.logger.debug '   ↻ Executing recursive role query'
    Rails.logger.silence(Logger::WARN) do
      connection.execute(recursive_search_query(*clean_searches, direction: direction)).to_a.flatten
    end
  end

  # Recursive Common Table Expression
  def self.recursive_search_query(*searches, direction: :up)
    search = searches.flatten.map { |n| "\"#{n}\"" }.join(', ')
    join_predicate = direction == :up ? 'r.id = cte.parent_id' : 'r.parent_id = cte.id'
    <<~SQL
      WITH RECURSIVE cte (id, name, parent_id) AS (
        SELECT id, name, parent_id FROM roles WHERE name IN (#{search})
        UNION ALL
        SELECT r.id, r.name, r.parent_id FROM roles r INNER JOIN cte ON #{join_predicate}
      )
      SELECT DISTINCT(name) FROM cte;
    SQL
  end

  def recursive_parents
    self.class.recursive_lookup(name)
  end

  def recursive_children
    self.class.recursive_lookdown(name)
  end

private

  def set_nil_parent_to_admin
    return if name == 'admin'

    self.parent ||= Role.find_by(name: 'admin')
  end

  def descends_from_admin?
    return true if name == 'admin'
    return true if persisted? && recursive_parents.include?('admin')
    return true if parent&.recursive_parents&.include?('admin')

    errors.add(:parent, 'must descend from :admin')
  end

  def admin_no_parent_id
    return unless name == 'admin' && parent_id.present?

    errors.add(:parent, 'must not be set for :admin')
  end
end
