# frozen_string_literal: true

class StandingCommitteeOffice < ApplicationRecord
  include Excom

  belongs_to :user

  before_validation { self.chair = false if executive? }
  before_create { self.term_expires_at = term_start_at + term_length.years unless executive? }
  before_create { self.committee_name = committee_name.downcase }
  after_save { update_excom_group if committee_name == 'executive' }

  validate :valid_committee_name, :only_one_chair
  validates :user_id, uniqueness: { scope: :committee_name }

  default_scope { ordered }
  scope :current, -> { where('term_expires_at IS NULL OR term_expires_at > ?', Time.now) }
  scope :chair_first, -> { order(chair: :asc) }

  def self.committees
    %w[executive auditing nominating rules]
  end

  def self.committee_titles
    committees.map(&:titleize)
  end

  def self.mail_all(committee_name)
    current.where(committee_name: committee_name).map { |c| c&.user&.email }.uniq.compact
  end

  def years_remaining
    executive? ? 1 : ((term_expires_at - Time.now) / 1.year).ceil
  end

  def term_year
    executive? ? 1 : term_length - years_remaining + 1
  end

  def term_fraction
    executive? ? '' : "[#{term_year}/#{term_length}]"
  end

private

  def valid_committee_name
    committee_name.downcase.in? %w[executive auditing nominations rules]
  end

  def only_one_chair
    StandingCommitteeOffice.current.where(committee_name: committee_name)
                           .where(chair: true).count <= 1
  end

  def executive?
    committee_name.casecmp('executive').zero?
  end
end
