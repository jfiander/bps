require 'rails_helper'

RSpec.describe MemberApplicant, type: :model do
  context 'primary' do
    before(:each) do
      @application = FactoryBot.build(:member_application)
      @applicant = FactoryBot.build(
        :member_applicant, member_application: @application, primary: true
      )
    end

    it 'should require names, full address, and a phone number' do
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

  context 'additional' do
    before(:each) do
      @application = FactoryBot.build(:member_application)
      @applicant = FactoryBot.build(
        :member_applicant, member_application: @application
      )
    end

    it 'should require names' do
      @applicant.validate
      expect(@applicant.errors.messages).to eql(
        first_name: ["can't be blank"],
        last_name: ["can't be blank"]
      )
    end

    it "should refuse an application with a member's email address" do
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
