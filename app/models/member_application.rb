class MemberApplication < ApplicationRecord
  has_many :member_applicants
  accepts_nested_attributes_for :member_applicants

  validates :member_applicants, presence: true

  def primary
    member_applicants.find_by(primary: true)
  end

  def additional
    member_applicants.where(primary: false)
  end

  def amount_due
    if additional.present?
      134 + additional.count
    elsif primary.member_type == 'Apprentice'
      12
    else
      89
    end
  end
end
