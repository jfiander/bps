# frozen_string_literal: true

class Registration < ApplicationRecord
  payable
  belongs_to :user, optional: true
  belongs_to :event
  has_many :registration_options

  attr_accessor :selections, :certificate

  belongs_to(
    :main_registration,
    class_name: 'Registration', optional: true, inverse_of: :additional_registrations
  )
  has_many(
    :additional_registrations,
    class_name: 'Registration', inverse_of: :main_registration, foreign_key: 'main_registration_id'
  )

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

    regular_payment_amount
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
    super && !(event.cutoff? && event.advance_payment) && main_registration_id.nil?
  end

  def display_name(html: true, truncate: false)
    return user.full_name(html: html) if user
    return name if name.present?
    return email unless truncate

    address, domain = email.split('@')
    short = address.truncate(12)
    "#{short}@#{domain}"
  end

  # Console helpers for building registrations without registering via the UI
  #
  # TODO: Add coverage
  #
  # :nocov:
  def available_options
    event.event_selections.each_with_object({}) do |event_selection, hash|
      hash[event_selection.description] =
        event_selection.event_options.each_with_object({}) do |option, h|
          h[option.name] = option.id
        end
    end
  end

  def select_option(string)
    available_options.each_value do |selections|
      selections.each do |name, id|
        return registration_options.build(event_option_id: id) if name =~ /#{string}/i
      end
    end
  end

  def select_option!(string)
    result = select_option(string)
    raise "Selection not found: #{string}" if result.nil?

    save!
  end
  # :nocov:

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

  def regular_payment_amount
    own_cost = event.get_cost(member: user&.present?)
    base_cost = own_cost + event.additional_registration_cost.to_i
    return base_cost unless additional_registrations.any?

    base_cost + (own_cost * additional_registrations.size)
  end
end
