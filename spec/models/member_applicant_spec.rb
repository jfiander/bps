# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MemberApplicant, type: :model do
  context 'with only a primary applicant' do
    before do
      @application = FactoryBot.build(:member_application)
      @applicant = FactoryBot.build(
        :member_applicant,
        member_application: @application,
        primary: true,
        first_name: '',
        last_name: ''
      )
    end

    it 'requires names, full address, and a phone number' do
      @applicant.validate
      expect(@applicant.errors.messages).to eql(
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
    before do
      @application = FactoryBot.build(:member_application)
      @applicant = FactoryBot.build(:member_applicant, member_application: @application, first_name: '', last_name: '')
    end

    it 'requires names' do
      @applicant.validate
      expect(@applicant.errors.messages).to eql(first_name: ["can't be blank"], last_name: ["can't be blank"])
    end

    it "refuses an application with a member's email address" do
      FactoryBot.create(:user, email: @applicant.email)
      @applicant.validate
      expect(@applicant.errors.messages).to eql(
        first_name: ["can't be blank"],
        last_name: ["can't be blank"],
        email: ['is already taken']
      )
    end
  end
end
