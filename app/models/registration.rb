class Registration < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :event

  before_validation :convert_email_to_user

  validate :email_or_user_present, :no_duplicate_registrations

  scope :current,  -> { all.find_all { |r| r.event.expires_at.future? } }
  scope :expired,  -> { all.find_all { |r| r.event.expires_at.past? } }
  scope :for_user, ->(user_id) { where(user_id: user_id) }

  after_create :notify_on_create
  after_create :confirm_public, if: :public_registration?

  acts_as_paranoid

  private
  def email_or_user_present
    errors.add(:base, 'Must have a user or event') unless user.present? || email.present?
  end

  def no_duplicate_registrations
    errors.add(:base, 'Duplicate') unless Registration.where(user: user, email: email, event: event).where.not(id: id).blank?
  end

  def notify_on_create
    RegistrationMailer.send_new(self).deliver
  end

  def confirm_public
    RegistrationMailer.send_public(self).deliver
  end

  def public_registration?
    email.present? && user.blank?
  end

  def convert_email_to_user
    return unless public_registration?
    return unless (user = User.find_by(email: email))

    self.user = user
    self.email = nil
  end
end
