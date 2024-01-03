# frozen_string_literal: true

class StandingCommitteeOffice < ApplicationRecord
  COMMITTEES = %w[executive auditing nominating rules].freeze

  include Excom
  extend Ordered

  belongs_to :user

  before_validation { self.chair = false if executive? }
  before_create do
    self.term_expires_at = term_start_at + term_length.years unless executive? || indefinite?
  end
  before_create { self.committee_name = committee_name.downcase }
  after_save { update_excom_group if committee_name == 'executive' }

  validate :only_one_current_chair, :no_duplicate_assignments
  validates :committee_name, presence: COMMITTEES

  scope :current, -> { where('term_expires_at IS NULL OR term_expires_at > ?', Time.zone.now) }
  scope :chair_first, -> { order(chair: :desc) }

  class << self
    COMMITTEES.each do |committee|
      define_method("#{committee}?") do |user_id|
        exists?(committee_name: committee, user_id: user_id)
      end
    end
  end

  def self.committee_titles
    COMMITTEES.map(&:titleize)
  end

  def self.mail_all(committee_name)
    current.where(committee_name: committee_name).map { |c| c&.user&.email }.uniq.compact
  end

  def years_remaining
    no_term_length? ? 1 : ((term_expires_at - Time.zone.now) / 1.year).ceil
  end

  def term_year
    no_term_length? ? 1 : term_length - years_remaining + 1
  end

  def term_fraction
    no_term_length? ? '' : "year #{term_year} of #{term_length}"
  end

  def current?
    term_expires_at.present? && term_expires_at > Time.zone.now
  end

  def no_term_length?
    executive? || indefinite?
  end

private

  def only_one_current_chair
    return true if !chair || siblings(chair: true).none?

    errors.add(:chair, 'can only have one current chair per committee')
  end

  def no_duplicate_assignments
    return true if siblings(user: user).none?

    errors.add(:chair, 'can only have one current assignment per committee')
  end

  def siblings(**where_opts)
    StandingCommitteeOffice.current.where(committee_name: committee_name).where(where_opts) - [self]
  end

  COMMITTEES.each do |committee|
    define_method("#{committee}?") do
      committee_name.casecmp(committee).zero?
    end
  end
end
