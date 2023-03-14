# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BPS::PDF::Receipt, type: :lib do
  let(:user) { create(:user) }

  before { generic_seo_and_ao }

  it 'successfullies generate a receipt for a user registration' do
    user_reg = create(:registration, user: user)
    user_reg.payment.paid!('1234567890')
    user_reg.payment.update(cost_type: 'Member')
    expect { user_reg.payment.receipt! }.not_to raise_error
  end

  it 'successfullies generate a receipt for an email registration' do
    email_reg = create(
      :registration, email: 'example@example.com', override_cost: 1, override_comment: 'Overridden'
    )
    expect { email_reg.payment.receipt! }.not_to raise_error
  end

  it 'successfullies generate a receipt for a member application' do
    member_app = create(:member_application, :with_primary)
    expect { member_app.payment.receipt! }.not_to raise_error
  end

  it 'successfullies generate a receipt for annual dues' do
    payment = create(:payment, parent: user)
    expect { payment.receipt! }.not_to raise_error
  end
end
