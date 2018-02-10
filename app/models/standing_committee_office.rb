class StandingCommitteeOffice < ApplicationRecord
  belongs_to :user

  before_validation { self.chair = false if executive? }
  before_create { self.term_expires_at = self.term_start_at + self.term_length.years unless executive? }
  before_create { self.committee_name = self.committee_name.downcase }

  validate :valid_committee_name, :only_one_chair
  validates :user_id, uniqueness: { scope: :committee_name }

  scope :current,     -> { where("term_expires_at IS NULL OR term_expires_at > ?", Time.now) }
  scope :chair_first, -> { order(chair: :asc) }
  scope :ordered,     -> {
    order <<~SQL
      CASE
        WHEN committee_name = 'executive'  THEN '1'
        WHEN committee_name = 'auditing'   THEN '2'
        WHEN committee_name = 'nominating' THEN '3'
        WHEN committee_name = 'rules'      THEN '4'
      END
    SQL
  }

  acts_as_paranoid

  def self.committees
    %w[executive auditing nominating rules]
  end

  def self.committee_titles
    committees.map(&:titleize)
  end

  def years_remaining
    return 1 if executive?
    ((term_expires_at - Time.now) / 1.year).ceil
  end

  def term_year
    return 1 if executive?
    term_length - years_remaining + 1
  end

  def term_fraction
    return "" if executive?
    "[#{term_year}/#{term_length}]"
  end

  private
  def valid_committee_name
    committee_name.downcase.in? %w[executive auditing nominations rules]
  end

  def only_one_chair
    StandingCommitteeOffice.current.where(committee_name: committee_name).where(chair: true).count <= 1
  end

  def executive?
    self.committee_name.casecmp("executive") == 0
  end
end
