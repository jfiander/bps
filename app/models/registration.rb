class Registration < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :event

  validate :email_or_user_present, :no_duplicate_registrations

  scope :current,  -> { all.find_all { |r| r.event.expires_at.future? } }
  scope :expired,  -> { all.find_all { |r| r.event.expires_at.past? } }
  scope :for_user, ->(user_id) { where(user_id: user_id) }

  after_create { notify_on_create }

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
end
