class BridgeOffice < ApplicationRecord
  belongs_to :user, optional: true

  def self.departments(assistants: false)
    depts = %w[commander executive educational administrative secretary treasurer]
    depts += %w[asst_educational asst_secretary] if assistants
    depts
  end

  before_validation do
    self.office = self.office.to_s
    BridgeOffice.where.not(office: self.office).where(user: self.user).update_all(user_id: nil)
  end

  validates :user_id, uniqueness: true, allow_nil: true
  validates :office,  uniqueness: true
  validate :valid_office

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
    BridgeOffice.title(self.office)
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

  def self.title(office)
    title = office.gsub("asst_", "Assistant ").titleize
    %w[Executive Educational Administrative].any? { |o| o.in? title } ? "#{title} Officer" : title
  end

  private
  def valid_office
    return true if office.in? BridgeOffice.departments(assistants: true)
    errors.add(:office, "must be in BridgeOffice.departments(assistants: true)")
  end
end
