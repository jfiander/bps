# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Role, type: :model do
  it 'descends from admin' do
    orphan = FactoryBot.build(:role, name: 'orphan')

    expect(orphan.valid?).to be(false)
    expect(orphan.errors.messages).to eql(parent: ['must descend from :admin'])
  end

  it 'returns the appropriate icons hash' do
    FactoryBot.build(:role, name: 'orphan', icon: 'user').save(validate: false)

    expect(Role.icons).to eq(
      { all: 'globe', excom: 'leaf-oak', orphan: 'user' }
    )
  end
end
