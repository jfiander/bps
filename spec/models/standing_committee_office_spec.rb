# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StandingCommitteeOffice do
  let(:executive) do
    create(
      :standing_committee_office,
      committee_name: 'executive',
      term_start_at: Time.zone.now.beginning_of_year,
      term_length: 3
    )
  end
  let(:auditing) do
    create(
      :standing_committee_office,
      committee_name: 'auditing',
      term_start_at: Time.zone.now.beginning_of_year - 1.year,
      term_length: 3
    )
  end

  describe '#current?' do
    it 'returns true if current' do
      auditing.term_expires_at = 1.week.from_now

      expect(auditing.current?).to be(true)
    end

    it 'returns false if expired' do
      auditing.term_expires_at = 1.week.ago

      expect(auditing.current?).to be(false)
    end

    it 'treats nil expiration date as expired' do
      auditing.term_expires_at = nil

      expect(auditing.current?).to be(false)
    end
  end

  describe 'display details' do
    context 'with the executive committee' do
      it 'always returns 1 year remaining' do
        expect(executive.years_remaining).to be(1)
      end

      it 'always returns term year 1' do
        expect(executive.term_year).to be(1)
      end

      it 'always returns a blank term fraction' do
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
        expect(auditing.term_fraction).to eql('year 2 of 3')
      end
    end
  end

  it 'generates the correct mailing list' do
    e1 = create(:standing_committee_office, committee_name: 'executive')
    e2 = create(:standing_committee_office, committee_name: 'executive')
    create(:standing_committee_office, committee_name: 'auditing')

    expect(described_class.mail_all(:executive).sort).to eql([e1.user.email, e2.user.email].sort)
  end

  it 'rejects multiple current chairs' do
    auditing.update(chair: true)
    second_chair = build(:standing_committee_office, committee_name: 'auditing', chair: true)

    expect(second_chair).not_to be_valid
  end

  it 'rejects multiple current users' do
    second_assignment = build(:standing_committee_office, committee_name: 'auditing', user: auditing.user)

    expect(second_assignment).not_to be_valid
  end
end
