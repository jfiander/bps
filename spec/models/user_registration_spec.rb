# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserRegistration, type: :model do
  it 'should mirror paid? from its registration' do
    reg = register.first
    expect(reg.paid?).to eql(reg.user_registrations.first.paid?)

    reg.payment.paid!('testing')
    expect(reg.paid?).to eql(reg.user_registrations.first.paid?)
  end

  it 'should not allow destroying if paid' do
    reg = register.first
    reg.payment.paid!('testing')

    expect { reg.user_registrations.first.destroy }.to raise_error(
      RuntimeError, 'The associated registration has been paid, so this cannot be destroyed.'
    )
  end

  it 'should require a user or email address' do
    ur = FactoryBot.build(:user_registration, registration: FactoryBot.build(:registration))

    expect(ur.valid?).to be(false)
    expect(ur.errors.messages).to eql(user: ['or email must be present'])
  end

  it 'should not allow duplicate user_registrations' do
    reg = register.first
    ur = reg.user_registrations.first
    ur_2 = FactoryBot.build(:user_registration, registration: reg, user: ur.user, email: ur.email)

    expect(ur_2.valid?).to be(false)
    expect(ur_2.errors.messages).to eql(base: ['Duplicate'])
  end
end
