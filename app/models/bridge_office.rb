class BridgeOffice < ApplicationRecord
  belongs_to :user

  before_validation { self.update(office: self.office.to_s) }

  validates :office,  uniqueness: true
  validates :user_id, uniqueness: true
  validates :office, inclusion: { in: %w[commander executive educational
    administrative secretary treasurer asst_educational asst_secretary],
    message: "%{value} is not a valid office" }

  scope :heads,      -> { where.not("office LIKE ?", "asst_%") }
  scope :assistants, -> { where("office LIKE ?", "asst_%") }
  scope :ordered,    -> {
    order("CASE
      WHEN office = 'commander'        THEN '1'
      WHEN office = 'executive'        THEN '2'
      WHEN office = 'administrative'   THEN '3'
      WHEN office = 'educational'      THEN '4'
      WHEN office = 'secretary'        THEN '5'
      WHEN office = 'treasurer'        THEN '6'
      WHEN office = 'asst_educational' THEN '7'
      WHEN office = 'asst_secretary'   THEN '8'
    END"
    )
  }

  def title
    t = case self.office
    when "commander", "secretary", "treasurer"
      self.office.titleize
    when "executive", "educational", "administrative"
      self.office.titleize
    when "asst_educational", "asst_secretary"
      self.office.gsub("asst_", "Assistant ").titleize
    end
    t += " Officer" if %w[Executive Educational Administrative].any? { |o| o.in? t }

    t
  end
end
