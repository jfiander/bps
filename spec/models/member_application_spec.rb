# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MemberApplication, type: :model do
  let(:single_application) { FactoryBot.create(:single_application) }
  let(:family_application) { FactoryBot.create(:family_application) }
  let(:apprentice_application) { FactoryBot.create(:apprentice_application) }

  context 'single application' do
    it 'should have one applicant' do
      expect(single_application.member_applicants.count).to eql(1)
    end

    it 'should have the single member cost' do
      expect(single_application.payment_amount).to eql(89)
    end

    it 'should have the apprentice member cost' do
      expect(apprentice_application.payment_amount).to eql(12)
    end
  end

  context 'family application' do
    it 'should have two members in a family application' do
      expect(family_application.member_applicants.count).to eql(2)
    end

    it 'should have the family member cost' do
      expect(family_application.payment_amount).to eql(135)
    end
  end

  it 'should not allow non-excom members to approve applications' do
    approver = FactoryBot.create(:user)
    expect(family_application.approve!(approver)).to eql(requires: :excom)
  end

  it 'should approve a new member' do
    approver = generic_seo_and_ao[:ao].user
    expect { family_application.approve!(approver) }.not_to raise_error
  end
end
