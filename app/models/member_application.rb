# frozen_string_literal: true

class MemberApplication < ApplicationRecord
  payable
  has_many :member_applicants
  accepts_nested_attributes_for :member_applicants

  has_one :approver, class_name: 'User'

  validates :member_applicants, presence: true

  scope :pending, -> { where(approved_at: nil).includes(:member_applicants) }

  def primary
    member_applicants.select(&:primary).first
  end

  def additional
    member_applicants.reject(&:primary)
  end

  def payment_amount
    return (139 + additional.count) if additional.present?
    return 12 if primary.member_type == 'Apprentice'

    93
  end

  def approve!(approving_user)
    return { requires: :excom } unless approving_user.excom?

    update(approved_at: Time.zone.now, approver_id: approving_user.id)

    parent = create_primary_user(primary)
    users = [parent]

    additional&.each do |member|
      users << User.create!(user_hash(member).merge(parent_id: parent.id))
    end

    send_approval_notices(users)
  end

private

  def user_hash(applicant)
    {
      certificate: SecureRandom.hex(8),
      first_name: applicant.first_name,
      last_name: applicant.last_name,
      email: applicant.email,
      password: SecureRandom.hex(32)
    }
  end

  def create_primary_user(primary)
    User.create!(
      user_hash(primary).merge(
        address_1: primary.address_1,
        address_2: primary.address_2,
        city: primary.city,
        state: primary.state,
        zip: primary.zip
      )
    )
  end

  def send_approval_notices(users)
    MemberApplicationMailer.approved(self).deliver
    MemberApplicationMailer.approval_notice(self).deliver
    users.map(&:invite!)
  end
end
