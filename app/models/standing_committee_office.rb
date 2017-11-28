class StandingCommitteeOffice < ApplicationRecord
  belongs_to :user

  before_create { self.term_expires_at = self.term_start_at + self.term_length.years }

  validates :committee_name, inclusion: { in: %w[executive auditing nominations rules] }
  validates :user_id, uniqueness: { scope: :committee_name }
  validates :chair, uniqueness: { scope: :committee_name }

  scope :current, -> { where("term_expires_at > ?", Time.now) }

  def self.committees
    %w[executive auditing nominations rules]
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
