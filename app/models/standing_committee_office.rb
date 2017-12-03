class StandingCommitteeOffice < ApplicationRecord
  belongs_to :user

  before_create { self.term_expires_at = self.term_start_at + self.term_length.years }

  validates :committee_name, inclusion: { in: %w[executive auditing nominations rules] }
  validates :user_id, uniqueness: { scope: :committee_name }
  validates :chair, uniqueness: { scope: :committee_name }

  scope :current,     -> { where("term_expires_at > ?", Time.now) }
  scope :chair_first, -> { order(chair: :desc) }
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

  def self.committees
    %w[executive auditing nominating rules]
  end

  def years_remaining
    ((term_expires_at - Time.now) / 1.year).ceil
  end

  def term_year
    term_length - years_remaining + 1
  end

  def term_fraction
    "[#{term_year}/#{term_length}]"
  end
end
