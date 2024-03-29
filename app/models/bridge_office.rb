# frozen_string_literal: true

class BridgeOffice < ApplicationRecord
  include Excom
  extend Ordered

  EMAILS = {
    commander: 'cdr', executive: 'xo', administrative: 'ao',
    educational: 'seo', secretary: 'secretary', treasurer: 'treasurer',
    asst_educational: 'aseo', asst_secretary: 'asec'
  }.freeze

  belongs_to :user, optional: true

  def self.departments(assistants: false)
    depts = %w[commander executive educational administrative secretary treasurer]
    depts += %w[asst_educational asst_secretary] if assistants
    depts
  end

  before_validation do
    self.office = office.to_s
    # rubocop:disable Rails/SkipsModelValidations
    BridgeOffice.other_than(office).where(user: user).update_all(user_id: nil)
    # rubocop:enable Rails/SkipsModelValidations
  end

  after_save { update_excom_group }

  validates :user_id, uniqueness: true, allow_nil: true
  validates :office,  uniqueness: true
  validate :valid_office

  scope :other_than, ->(office) { where.not(office: office) }
  scope :heads,      -> { where.not('office LIKE ?', 'asst_%') }
  scope :assistants, -> { where('office LIKE ?', 'asst_%') }

  def self.preload
    all.map { |b| { b.user_id => b.office } }.reduce({}, :merge)
  end

  def self.mail_all(include_asst: false)
    bridge = BridgeOffice.includes(:user)
    bridge = bridge.heads unless include_asst
    bridge.map { |b| b&.user&.email }.uniq.compact
  end

  def department
    BridgeOffice.department(office)
  end

  def title
    BridgeOffice.title(office)
  end

  def email
    "#{EMAILS[office.to_sym]}@bpsd9.org"
  end

  def self.department(office)
    office.gsub('asst_', 'Assistant ').titleize
  end

  def self.title(office)
    title = department(office)
    %w[Executive Educational Administrative].any? { |o| o.in? title } ? "#{title} Officer" : title
  end

  def self.advance(new_ao_user_id = nil)
    cdr = BridgeOffice.find_by(office: 'commander')
    xo = BridgeOffice.find_by(office: 'executive')
    ao = BridgeOffice.find_by(office: 'administrative')

    cdr.update(user_id: xo.user_id)
    xo.update(user_id: ao.user_id)
    ao.update(user_id: new_ao_user_id)
  end

private

  def valid_office
    return true if office.in? BridgeOffice.departments(assistants: true)

    errors.add(:office, 'must be in BridgeOffice.departments(assistants: true)')
  end
end
