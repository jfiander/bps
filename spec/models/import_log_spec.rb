# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImportLog, type: :model do
  it 'returns the most recent from latest' do
    FactoryBot.create_list(:import_log, 3)
    ImportLog.first.update(created_at: Time.zone.now + 10)

    expect(ImportLog.latest).to eql(ImportLog.first)
  end
end
