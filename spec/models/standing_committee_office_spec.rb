# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StandingCommitteeOffice, type: :model do
  describe 'display details' do
    context 'with the executive committee' do
      before do
        @standing = FactoryBot.create(
          :standing_committee_office,
          committee_name: 'executive',
          term_start_at: Time.now.beginning_of_year,
          term_length: 3
        )
      end

      it 'alwayses return 1 year remaining' do
        expect(@standing.years_remaining).to be(1)
      end

      it 'alwayses return term year 1' do
        expect(@standing.term_year).to be(1)
      end

      it 'alwayses return a blank term fraction' do
        expect(@standing.term_fraction).to eql('')
      end
    end

    context 'with any other committee' do
      before do
        @standing = FactoryBot.create(
          :standing_committee_office,
          committee_name: 'auditing',
          term_start_at: Time.now.beginning_of_year - 1.year,
          term_length: 3
        )
      end

      it 'calculates the correct years remaining' do
        expect(@standing.years_remaining).to be(2)
      end

      it 'returns the correct term year' do
        expect(@standing.term_year).to be(2)
      end

      it 'returns the correct term fraction' do
        expect(@standing.term_fraction).to eql('[2/3]')
      end
    end
  end

  it 'generates the correct mailing list' do
    e1 = FactoryBot.create(:standing_committee_office, committee_name: 'executive')
    e2 = FactoryBot.create(:standing_committee_office, committee_name: 'executive')
    FactoryBot.create(:standing_committee_office, committee_name: 'auditing')

    expect(StandingCommitteeOffice.mail_all(:executive).sort).to eql([e1.user.email, e2.user.email].sort)
  end
end
