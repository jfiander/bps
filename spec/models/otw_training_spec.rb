# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OTWTraining do
  it 'orders correctly' do
    create(:otw_training, boc_level: 'Advanced Coastal Navigator', name: '5')
    create(:otw_training, boc_level: 'Coastal Navigator', name: '4')
    create(:otw_training, boc_level: 'Offshore Navigator', name: '3')
    create(:otw_training, boc_level: 'Inland Navigator', name: '2')
    create(:otw_training, boc_level: 'Coastal Navigator', name: '1')

    expect(described_class.all.ordered.map { |o| [o.boc_level, o.name] }).to eql(
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
