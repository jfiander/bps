# frozen_string_literal: true

class Registration < ApplicationRecord
  payable
  belongs_to :user, optional: true
  belongs_to :event
  has_many :registration_options

  before_validation :convert_email_to_user

  validate :email_or_user_present, :no_duplicate_registrations

  scope :current,  -> { all.find_all { |r| !r.event&.expired? } }
  scope :expired,  -> { all.find_all { |r| r.event&.expired? } }
  scope :for_user, ->(user_id) { where(user_id: user_id) }
  scope :not_refunded, (lambda do
    joins(:payment).where('payments.refunded IS NULL OR payments.refunded = ?', false)
  end)

  # Registrations can be created by a publicly-accessible interface.
  # Executing these queries will completely remove all traces of those from the database.
  #
  def self.obliterate_sql(start_at, end_at = nil)
    start_at = start_at.strftime('%Y-%m-%d %H:%M:%S')
    end_at = "AND created_at < \"#{end_at.strftime('%Y-%m-%d %H:%M:%S')}\"" unless end_at.nil?

    <<~SQL
      DELETE FROM registrations WHERE created_at > "#{start_at}" #{end_at};
      DELETE FROM payments WHERE parent_type = 'Registration' AND created_at > "#{start_at}" #{end_at};
      DELETE FROM versions WHERE item_type = 'Registration' AND created_at > "#{start_at}" #{end_at};
      DELETE FROM versions WHERE item_type = 'Payment' AND created_at > "#{start_at}" #{end_at};
    SQL
  end

  def self.obliterate!(start_at, end_at = nil)
    sql = obliterate_sql(start_at, end_at)
    queries = sql.split("\n")

    queries.each { |q| ApplicationRecord.connection.execute(q) }
  end

  delegate :promo_code, to: :payment

  # Normal amount for this registration
  #
  # For the actual amount paid, use `payment.amount`
  def payment_amount
    convert_email_to_user && save
    return override_cost if override_cost.present?

    event&.get_cost(member: user&.present?)
  end

  def cost?
    payment_amount&.positive?
  end

  def user?
    user.present?
  end

  def type
    event.course? ? 'course' : event.event_type.event_category
  end

  def payable?
    super && !(event.cutoff? && event.advance_payment)
  end

private

  def no_duplicate_registrations
    matches =
      Registration.not_refunded
                  .where.not(id: id)
                  .where(user: user, email: email, event: event)
    return if matches.blank?

    errors.add(:base, 'Duplicate')
  end

  def email_or_user_present
    return if user.present? || email.present?

    errors.add(:base, 'Must have a user or email')
  end

  def public_registration?
    email.present? && user.blank?
  end

  def convert_email_to_user
    return unless public_registration?
    return unless (user = User.find_by(email: email))

    self.email = nil
    self.user = user
  end
end
