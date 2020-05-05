# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenericPayment, type: :model do
  subject(:payment) { FactoryBot.create(:generic_payment, amount: 7, email: user.email) }

  let(:user) { FactoryBot.create(:user) }

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
end
