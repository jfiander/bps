# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MemberApplicant do
  let(:application) { build(:member_application) }
  let!(:primary) do
    build(
      :member_applicant,
      member_application: application,
      primary: true,
      first_name: '',
      last_name: ''
    )
  end

  context 'with only a primary applicant' do
    it 'requires names, full address, and a phone number' do
      primary.validate
      expect(primary.errors.messages.to_h).to eql(
        first_name: ["can't be blank"],
        last_name: ["can't be blank"],
        address_1: ["can't be blank"],
        city: ["can't be blank"],
        state: ["can't be blank"],
        zip: ["can't be blank"],
        base: ['At least one phone number is required']
      )
    end
  end

  context 'with an additional member' do
    let(:additional) do
      build(
        :member_applicant,
        member_application: application,
        primary: false,
        first_name: '',
        last_name: ''
      )
    end

    it 'requires names' do
      additional.validate
      expect(additional.errors.messages.to_h).to eql(first_name: ["can't be blank"], last_name: ["can't be blank"])
    end

    it "refuses an application with a member's email address" do
      create(:user, email: additional.email)

      additional.validate
      expect(additional.errors.messages.to_h).to eql(
        first_name: ["can't be blank"],
        last_name: ["can't be blank"],
        email: ['is already taken']
      )
    end
  end
end
