# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MemberApplication do
  let(:single_application) { create(:single_application) }
  let(:family_application) { create(:family_application) }
  let(:apprentice_application) { create(:apprentice_application) }

  context 'with a single application' do
    it 'has one applicant' do
      expect(single_application.member_applicants.count).to be(1)
    end

    it 'has the single member cost' do
      expect(single_application.payment_amount).to be(89)
    end

    it 'has the apprentice member cost' do
      expect(apprentice_application.payment_amount).to be(12)
    end
  end

  context 'with a family application' do
    it 'has two members in a family application' do
      expect(family_application.member_applicants.count).to be(2)
    end

    it 'has the family member cost' do
      expect(family_application.payment_amount).to be(135)
    end
  end

  it 'does not allow non-excom members to approve applications' do
    approver = create(:user)
    expect(family_application.approve!(approver)).to eql(requires: :excom)
  end

  it 'approves a new member' do
    approver = generic_seo_and_ao[:ao].user
    expect { family_application.approve!(approver) }.not_to raise_error
  end
end
