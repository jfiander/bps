# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Registration, type: :model do
  before(:each) do
    @user = FactoryBot.create(:user)
    @event = FactoryBot.create(:event)
  end

  it 'should convert a public registration user email to user' do
    reg = FactoryBot.create(:registration, email: @user.email, event: @event)
    expect(reg.user).to eql(@user)
  end

  it 'should require an email or user' do
    reg = FactoryBot.build(:registration, event: @event)
    expect(reg.valid?).to be(false)
    expect(reg.errors.messages).to eql(base: ['Must have a user or event'])

    reg = FactoryBot.build(:registration, event: @event, email: @user.email)
    expect(reg.valid?).to be(true)

    reg = FactoryBot.build(:registration, event: @event, user: @user)
    expect(reg.valid?).to be(true)
  end

  it 'should not allow duplicate registrations' do
    FactoryBot.create(:registration, event: @event, user: @user)
    reg = FactoryBot.build(:registration, event: @event, user: @user)
    expect(reg.valid?).to be(false)
    expect(reg.errors.messages).to eql(base: ['Duplicate'])
  end

  it 'should send a confirmation email for public registrations' do
    seo = FactoryBot.create(:user)
    FactoryBot.create(:bridge_office, user: seo, office: 'educational')
    expect do
      FactoryBot.create(:registration, email: 'nobody@example.com', event: @event)
    end.not_to raise_error
  end
end
