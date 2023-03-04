# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BridgeHelper do
  let!(:cdr) { create(:user, first_name: 'John', last_name: 'Doe') }
  let!(:com) { create(:user, first_name: 'Jane', last_name: 'Dore') }
  let!(:stand) { create(:user, first_name: 'Jack', last_name: 'Dodd') }
  let!(:standing_committee_office) { create(:standing_committee_office, user: stand) }
  let!(:bridge_office) { create(:bridge_office, user: cdr) }
  let!(:committee) { create(:committee, user: com) }
  let(:departments) do
    {
      commander: {
        head: {
          title: 'Commander',
          office: 'commander',
          email: 'cdr@bpsd9.org',
          user: {
            full_name: 'Cdr&nbsp;John&nbsp;Doe,&nbsp;AP',
            simple_name: 'John&nbsp;Doe',
            photo: 'https://static.bpsd9.org/no_profile.png'
          }
        },
        assistant: nil,
        committees: nil
      },
      executive: { head: nil, assistant: nil, committees: nil },
      educational: { head: nil, assistant: nil, committees: nil },
      administrative: {
        head: nil, assistant: nil, committees: [
          {
            name: 'rendezvous',
            user: {
              full_name: 'Lt&nbsp;Jane&nbsp;Dore,&nbsp;AP',
              simple_name: 'Jane&nbsp;Dore',
              photo: 'https://static.bpsd9.org/no_profile.png'
            },
            id: committee.id
          }
        ]
      },
      secretary: { head: nil, assistant: nil, committees: nil },
      treasurer: { head: nil, assistant: nil, committees: nil }
    }
  end
  let(:standing_committees) do
    {
      'executive' => [
        {
          id: standing_committee_office.id,
          simple_name: 'Jack&nbsp;Dodd',
          full_name: 'Lt&nbsp;Jack&nbsp;Dodd,&nbsp;AP',
          chair: false,
          term_fraction: ''
        }
      ]
    }
  end

  before { described_class.preload_user_data }

  it 'generates the correct values for the bridge selectors' do
    expect(described_class.bridge_selectors).to eql(
      departments: [
        %w[Commander commander],
        %w[Executive executive],
        %w[Educational educational],
        %w[Administrative administrative],
        %w[Secretary secretary],
        %w[Treasurer treasurer]
      ],
      bridge_offices: [
        %w[Commander commander],
        ['Executive Officer', 'executive'],
        ['Educational Officer', 'educational'],
        ['Administrative Officer', 'administrative'],
        %w[Secretary secretary],
        %w[Treasurer treasurer],
        ['Assistant Educational Officer', 'asst_educational'],
        ['Assistant Secretary', 'asst_secretary']
      ],
      standing_committees: %w[Executive Auditing Nominating Rules],
      users: [
        ['TBD', nil],
        ['Lt Jack Dodd, AP', stand.id],
        ['Cdr John Doe, AP', cdr.id],
        ['Lt Jane Dore, AP', com.id]
      ]
    )
  end

  it 'builds the correct bridge list' do
    expect(described_class.build_bridge_list).to eql(departments: departments, standing_committees: standing_committees)
  end
end
