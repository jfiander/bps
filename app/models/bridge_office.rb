class BridgeOffice < ApplicationRecord
  belongs_to :user, optional: true

  before_validation do
    self.office = self.office.to_s
    BridgeOffice.where.not(office: self.office).where(user: self.user).update_all(user_id: nil)
  end

  validates :user_id, uniqueness: true, allow_nil: true
  validates :office,  uniqueness: true, inclusion: { in: %w[commander executive educational
    administrative secretary treasurer asst_educational asst_secretary],
    message: "%{value} is not a valid office" }

  scope :heads,      -> { where.not("office LIKE ?", "asst_%") }
  scope :assistants, -> { where("office LIKE ?", "asst_%") }
  scope :ordered,    -> {
    order <<~SQL
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
  }

  def title
    %w[Executive Educational Administrative].any? { |o| o.in? department } ? "#{department} Officer" : department
  end

  def department
    self.office.gsub("asst_", "Assistant ").titleize
  end

  def email
    emails = {
      commander: "cdr",
      executive: "xo",
      administrative: "ao",
      educational: "seo",
      secretary: "secretary",
      treasurer: "treasurer",
      asst_educational: "aseo",
      asst_secretary: "asst_secretary"
    }
    "mailto:#{emails[office.to_sym]}@bpsd9.org"
  end
end
