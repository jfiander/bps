# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StandingCommitteeOffice, type: :model do
  describe 'display details' do
    context 'executive committee' do
      before(:each) do
        @standing = FactoryBot.create(
          :standing_committee_office,
          committee_name: 'executive',
          term_start_at: Time.now.beginning_of_year,
          term_length: 3
        )
      end

      it 'should always return 1 year remaining' do
        expect(@standing.years_remaining).to eql(1)
      end

      it 'should always return term year 1' do
        expect(@standing.term_year).to eql(1)
      end

      it 'should always return a blank term fraction' do
        expect(@standing.term_fraction).to eql('')
      end
    end

    context 'other committee' do
      before(:each) do
        @standing = FactoryBot.create(
          :standing_committee_office,
          committee_name: 'auditing',
          term_start_at: Time.now.beginning_of_year - 1.year,
          term_length: 3
        )
      end

      it 'should calculate the correct years remaining' do
        expect(@standing.years_remaining).to eql(2)
      end

      it 'should return the correct term year' do
        expect(@standing.term_year).to eql(2)
      end

      it 'should return the correct term fraction' do
        expect(@standing.term_fraction).to eql('[2/3]')
      end
    end
  end

  it 'should generate the correct mailing list' do
    e1 = FactoryBot.create(:standing_committee_office, committee_name: 'executive')
    e2 = FactoryBot.create(:standing_committee_office, committee_name: 'executive')
    FactoryBot.create(:standing_committee_office, committee_name: 'auditing')

    expect(StandingCommitteeOffice.mail_all(:executive).sort).to eql([e1.user.email, e2.user.email].sort)
  end
end
