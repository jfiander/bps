require 'rails_helper'

RSpec.describe BridgeHelper, type: :helper do
  before(:each) do
    cdr = FactoryBot.create(:user, first_name: 'John', last_name: 'Doe')
    com = FactoryBot.create(:user, first_name: 'Jane', last_name: 'Dore')
    stand = FactoryBot.create(:user, first_name: 'Jack', last_name: 'Dodd')
    @bridge_office = FactoryBot.create(:bridge_office, user: cdr)
    @committee = FactoryBot.create(:committee, user: com)
    @standing_committee_office = FactoryBot.create(:standing_committee_office, user: stand)
    BridgeHelper.preload_user_data
  end

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
      executive: {
        head: nil, assistant: nil, committees: nil
      },
      educational: {
        head: nil, assistant: nil, committees: nil
      },
      administrative: {
        head: nil, assistant: nil, committees: [
          {
            name: 'rendezvous',
            user: {
              full_name: 'Lt&nbsp;Jane&nbsp;Dore,&nbsp;AP',
              simple_name: 'Jane&nbsp;Dore',
              photo: 'https://static.bpsd9.org/no_profile.png'
            },
            id: 1
          }
        ]
      },
      secretary: {
        head: nil, assistant: nil, committees: nil
      },
      treasurer: {
        head: nil, assistant: nil, committees: nil
      }
    }
  end

  let(:standing_committees) do
    {
      'executive' => [
        {
          id: 1,
          simple_name: 'Jack&nbsp;Dodd',
          full_name: 'Lt&nbsp;Jack&nbsp;Dodd,&nbsp;AP',
          chair: false,
          term_fraction: ''
        }
      ]
    }
  end

  it 'should generate the correct values for the bridge selectors' do
    expect(BridgeHelper.bridge_selectors).to eql(
      {
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
          ['Lt Jack Dodd, AP', 3],
          ['Cdr John Doe, AP', 1],
          ['Lt Jane Dore, AP', 2]
        ]
      }
    )
  end

  it 'should build the correct bridge list' do
    expect(BridgeHelper.build_bridge_list).to eql(
      { departments: departments, standing_committees: standing_committees }
    )
  end
end
