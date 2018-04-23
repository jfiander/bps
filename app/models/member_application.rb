class MemberApplication < ApplicationRecord
  has_many :member_applicants
  accepts_nested_attributes_for :member_applicants

  has_one :approver, class_name: 'User'

  validates :member_applicants, presence: true

  scope :pending, -> { where(approved_at: nil).includes(:member_applicants) }

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

  def approve!(approving_user)
    return { requires: :excom } unless approving_user.excom?

    update(approved_at: Time.now, approver_id: approving_user.id)

    parent = User.create!(
      certificate: SecureRandom.hex(8),
      first_name: primary.first_name,
      last_name: primary.last_name,
      email: primary.email,
      address_1: primary.address_1,
      address_2: primary.address_2,
      city: primary.city,
      state: primary.state,
      zip: primary.zip,
      password: SecureRandom.hex(32)
    )
    users = [parent]

    additional&.each do |member|
      users << User.create!(
        certificate: SecureRandom.hex(8),
        first_name: member.first_name,
        last_name: member.last_name,
        email: member.email,
        address_1: member.address_1,
        address_2: member.address_2,
        city: member.city,
        state: member.state,
        zip: member.zip,
        parent_id: parent.id,
        password: SecureRandom.hex(32)
      )
    end

    MemberApplicationMailer.approved(self).deliver
    MemberApplicationMailer.approval_notice(self).deliver
    users.map(&:invite!)
  end
end