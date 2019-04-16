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

  describe 'certificate input' do
    before(:each) do
      @reg = register.first
      @urs = @reg.user_registrations.to_a
    end

    it 'should not add unknown certificates' do
      @reg.add(certificate: 'X123456')
      expect { @reg.validate! }.to raise_error(
        ActiveRecord::RecordInvalid,
        'Validation failed: User registrations user or email must be present'
      )
    end

    it 'should convert a certificate to that user' do
      user = FactoryBot.create(:user, certificate: 'E987654')
      @reg.add(certificate: 'E987654')
      expect(@reg.user_registrations.map(&:id)).not_to eql(@urs.map(&:id))
      expect(@reg.user_registrations.last.user).to eql(user)
    end
  end
end
