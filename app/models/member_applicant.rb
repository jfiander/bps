# frozen_string_literal: true

class MemberApplicant < ApplicationRecord
  belongs_to :member_application

  validates_presence_of %i[
    first_name last_name address_1 city state zip email
  ], if: :primary

  validates_presence_of %i[
    first_name last_name email
  ], unless: :primary

  validates :email, uniqueness: true

  validate :at_least_one_phone, if: :primary
  validate :email_not_a_member

  before_validation { self.member_type ||= 'Active' }

  def at_least_one_phone
    return if %w[phone_h phone_c phone_w].any? { |p| send(p).present? }
    errors.add :base, 'At least one phone number is required'
  end

  def email_not_a_member
    errors.add :email, 'is already taken' if User.where(email: email).present?
  end
end
