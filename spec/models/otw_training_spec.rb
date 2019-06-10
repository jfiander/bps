# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OTWTraining, type: :model do
  it 'orders correctly' do
    FactoryBot.create(:otw_training, boc_level: 'Advanced Coastal Navigator', name: '5')
    FactoryBot.create(:otw_training, boc_level: 'Coastal Navigator', name: '4')
    FactoryBot.create(:otw_training, boc_level: 'Offshore Navigator', name: '3')
    FactoryBot.create(:otw_training, boc_level: 'Inland Navigator', name: '2')
    FactoryBot.create(:otw_training, boc_level: 'Coastal Navigator', name: '1')

    expect(OTWTraining.all.ordered.map { |o| [o.boc_level, o.name] }).to eql(
      [
        ['Inland Navigator', '2'],
        ['Coastal Navigator', '1'],
        ['Coastal Navigator', '4'],
        ['Advanced Coastal Navigator', '5'],
        ['Offshore Navigator', '3']
      ]
    )
  end
end
