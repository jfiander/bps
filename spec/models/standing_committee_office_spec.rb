# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StandingCommitteeOffice, type: :model do
  let(:executive) do
    FactoryBot.create(
      :standing_committee_office,
      committee_name: 'executive',
      term_start_at: Time.zone.now.beginning_of_year,
      term_length: 3
    )
  end
  let(:auditing) do
    FactoryBot.create(
      :standing_committee_office,
      committee_name: 'auditing',
      term_start_at: Time.zone.now.beginning_of_year - 1.year,
      term_length: 3
    )
  end

  describe 'display details' do
    context 'with the executive committee' do
      it 'alwayses return 1 year remaining' do
        expect(executive.years_remaining).to be(1)
      end

      it 'alwayses return term year 1' do
        expect(executive.term_year).to be(1)
      end

      it 'alwayses return a blank term fraction' do
        expect(executive.term_fraction).to eql('')
      end
    end

    context 'with any other committee' do
      it 'calculates the correct years remaining' do
        expect(auditing.years_remaining).to be(2)
      end

      it 'returns the correct term year' do
        expect(auditing.term_year).to be(2)
      end

      it 'returns the correct term fraction' do
        expect(auditing.term_fraction).to eql('[2/3]')
      end
    end
  end

  it 'generates the correct mailing list' do
    e1 = FactoryBot.create(:standing_committee_office, committee_name: 'executive')
    e2 = FactoryBot.create(:standing_committee_office, committee_name: 'executive')
    FactoryBot.create(:standing_committee_office, committee_name: 'auditing')

    expect(described_class.mail_all(:executive).sort).to eql([e1.user.email, e2.user.email].sort)
  end

  it 'rejects multiple current chairs' do
    auditing.update_attribute(:chair, true)
    second_chair = FactoryBot.build(:standing_committee_office, committee_name: 'auditing', chair: true)

    expect(second_chair).to be_invalid
  end
end
