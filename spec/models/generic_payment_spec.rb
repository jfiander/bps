# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenericPayment do
  subject(:payment) { create(:generic_payment, amount: 7, email: user.email) }

  let(:user) { create(:user) }

  it 'reassigns to the found user' do
    expect(payment.email).to be_blank
    expect(payment.user_id).to eq(user.id)
  end

  it 'has the correct payment_amount' do
    expect(payment.payment_amount).to eq(7)
  end

  it 'generates the correct link' do
    expect(payment.link).to match(%r{/pay/\w+\z})
  end

  it 'is invalid without an email or user' do
    reg = build(:generic_payment, amount: 7)
    expect(reg.valid?).to be(false)
    expect(reg.errors.messages.to_h).to eql(base: ['Must have a user or email'])
  end
end
