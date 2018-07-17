# frozen_string_literal: true

class BridgeOffice < ApplicationRecord
  belongs_to :user, optional: true

  def self.departments(assistants: false)
    depts = %w[commander executive educational administrative secretary treasurer]
    depts += %w[asst_educational asst_secretary] if assistants
    depts
  end

  before_validation do
    self.office = office.to_s
    BridgeOffice.other_than(office).where(user: user).update_all(user_id: nil)
  end

  validates :user_id, uniqueness: true, allow_nil: true
  validates :office,  uniqueness: true
  validate :valid_office

  scope :other_than, ->(office) { where.not(office: office) }
  scope :heads,      -> { where.not('office LIKE ?', 'asst_%') }
  scope :assistants, -> { where('office LIKE ?', 'asst_%') }

  def self.ordered
    order Arel.sql(
      <<~SQL
        CASE
          WHEN office = 'commander'        THEN '1'
          WHEN office = 'executive'        THEN '2'
          WHEN office = 'educational'      THEN '3'
          WHEN office = 'administrative'   THEN '4'
          WHEN office = 'secretary'        THEN '5'
          WHEN office = 'treasurer'        THEN '6'
          WHEN office = 'asst_educational' THEN '7'
          WHEN office = 'asst_secretary'   THEN '8'
        END
      SQL
    )
  end

  def self.preload
    all.map { |b| {b.user_id => b.office} }.reduce({}, :merge)
  end

  def department
    BridgeOffice.department(office)
  end

  def title
    BridgeOffice.title(office)
  end

  def email
    emails = {
      commander: 'cdr',
      executive: 'xo',
      administrative: 'ao',
      educational: 'seo',
      secretary: 'secretary',
      treasurer: 'treasurer',
      asst_educational: 'aseo',
      asst_secretary: 'asst_secretary'
    }
    "#{emails[office.to_sym]}@bpsd9.org"
  end

  def self.department(office)
    office.gsub('asst_', 'Assistant ').titleize
  end

  def self.title(office)
    title = department(office)
    if %w[Executive Educational Administrative].any? { |o| o.in? title }
      "#{title} Officer"
    else
      title
    end
  end

  private

  def valid_office
    return true if office.in? BridgeOffice.departments(assistants: true)
    errors.add(:office, 'must be in BridgeOffice.departments(assistants: true)')
  end
end
