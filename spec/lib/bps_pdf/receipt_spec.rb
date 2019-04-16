# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BpsPdf::Receipt, type: :lib do
  before do
    generic_seo_and_ao
  end

  it 'successfully generates a receipt for a user registration' do
    reg = register.first
    reg.payment.paid!('1234567890')
    reg.payment.update(cost_type: 'Member')
    expect { reg.payment.receipt! }.not_to raise_error
  end

  it 'successfully generates a receipt for an email registration' do
    reg = register(email: 'test@example.com').first
    expect { reg.payment.receipt! }.not_to raise_error
  end

  it 'successfully generates a receipt with an override cost' do
    reg = register(email: 'test@example.com').first
    reg.update(override_cost: 1, override_comment: 'Overridden')
    expect { reg.payment.receipt! }.not_to raise_error
  end

  it 'successfully generates a receipt for a member application' do
    member_app = FactoryBot.create(:member_application, :with_primary)
    expect { member_app.payment.receipt! }.not_to raise_error
  end

  it 'successfully generates a receipt for annual dues' do
    payment = FactoryBot.create(:payment, parent: FactoryBot.create(:user))
    expect { payment.receipt! }.not_to raise_error
  end
end
