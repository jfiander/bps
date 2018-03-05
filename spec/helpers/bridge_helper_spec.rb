require 'rails_helper'

RSpec.describe BridgeHelper, type: :helper do
  before(:each) do
    @bridge_office = FactoryBot.create(:bridge_office)
    @committee = FactoryBot.create(:committee)
    @standing_committee_office = FactoryBot.create(:standing_committee_office)
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
            full_name: 'Cdr&nbsp;First_4&nbsp;Last_4,&nbsp;AP',
            simple_name: 'First_4&nbsp;Last_4',
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
              full_name: 'Lt&nbsp;First_5&nbsp;Last_5,&nbsp;AP',
              simple_name: 'First_5&nbsp;Last_5',
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
          simple_name: 'First_6&nbsp;Last_6',
          full_name: 'Lt&nbsp;First_6&nbsp;Last_6,&nbsp;AP',
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
          ['Cdr First_1 Last_1, AP', 1],
          ['Lt First_2 Last_2, AP', 2],
          ['Lt First_3 Last_3, AP', 3]
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
