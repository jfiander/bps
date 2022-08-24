# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImportLog, type: :model do
  it 'returns the most recent from latest' do
    FactoryBot.create_list(:import_log, 3)
    described_class.first.update(created_at: Time.zone.now + 10)

    expect(described_class.latest).to eql(described_class.first)
  end

  it 'decodes proto' do
    log = FactoryBot.create(:import_log, proto: BPS::Update::UserDataImport.new.to_proto)

    expect(log.decode).to be_a(BPS::Update::UserDataImport)
  end
end
