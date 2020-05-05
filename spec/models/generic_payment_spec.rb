require 'rails_helper'

RSpec.describe GenericPayment, type: :model do
  let(:user) { FactoryBot.create(:user) }

  subject { FactoryBot.create(:generic_payment, amount: 7, email: user.email) }

  it 'reassigns to the found user' do
    expect(subject.email).to be_blank
    expect(subject.user_id).to eq(user.id)
  end

  it 'has the correct payment_amount' do
    expect(subject.payment_amount).to eq(7)
  end

  it 'generates the correct link' do
    expect(subject.link).to match(%r{/pay/\w+\z})
  end
end
