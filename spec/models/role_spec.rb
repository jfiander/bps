# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Role do
  it 'descends from admin', :aggregate_failures do
    orphan = build(:role, name: 'orphan')

    expect(orphan.valid?).to be(false)
    expect(orphan.errors.messages.to_h).to eql(parent: ['must descend from :admin'])
  end

  it 'cannot set a parent_id for admin', :aggregate_failures do
    admin = build(:role, name: 'admin', parent_id: 1)

    expect(admin.valid?).to be(false)
    expect(admin.errors.messages.to_h).to eql(parent: ['must not be set for :admin'])
  end

  it 'returns the appropriate icons hash' do
    build(:role, name: 'orphan', icon: 'user').save(validate: false)

    expect(described_class.icons).to eq(
      { all: 'globe', excom: 'chevron-circle-down', orphan: 'user' }
    )
  end

  describe 'recursive lookups' do
    let!(:admin) { create(:role, name: 'admin') }
    let!(:education) { create(:role, name: 'education') }
    let!(:course) { create(:role, name: 'course', parent: education) }

    describe '#recursive_parents' do
      subject { education.recursive_parents }

      it { is_expected.to eq(%w[education admin]) }
    end

    describe '#recursive_children' do
      subject { education.recursive_children }

      it { is_expected.to eq(%w[education course]) }
    end
  end
end
