# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Role, type: :model do
  it 'should descend from admin' do
    orphan = FactoryBot.build(:role, name: 'orphan')

    expect(orphan.valid?).to be(false)
    expect(orphan.errors.messages).to eql(parent: ['must descend from :admin'])
  end
end
