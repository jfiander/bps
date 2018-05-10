# frozen_string_literal: true

class RegistrationMailerPreview < ActionMailer::Preview
  def registered
    RegistrationMailer.registered(reg_member_free)
  end

  def cancelled
    RegistrationMailer.cancelled(reg_member_free)
  end

  def paid
    RegistrationMailer.paid(reg_member_free)
  end

  def confirm_event
    RegistrationMailer.confirm(registration_ao)
  end

  def remind
    RegistrationMailer.remind(registration)
  end

  def confirm_member_free
    RegistrationMailer.confirm(reg_member_free)
  end

  def confirm_member_paid
    RegistrationMailer.confirm(reg_member_paid)
  end

  def confirm_public_free
    RegistrationMailer.confirm(reg_public_free)
  end

  def confirm_public_paid
    RegistrationMailer.confirm(reg_public_paid)
  end

  private

  def reg_member_free
    Registration.where.not(user: nil)
                .select { |r| r.payment_amount.zero? }.last
  end

  def reg_member_paid
    Registration.where.not(user: nil)
                .select { |r| r.payment_amount.positive? }.last
  end

  def reg_public_free
    Registration.where(user: nil)
                .select { |r| r.payment_amount.zero? }.last
  end

  def reg_public_paid
    Registration.where(user: nil)
                .select { |r| r.payment_amount.positive? }.last
  end

  def registration_ao
    Registration.all.select { |r| r.event.category == 'meeting' }.last
  end
end
