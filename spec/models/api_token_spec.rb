# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiToken, type: :model do
  let(:token) { FactoryBot.create(:api_token) }

  it 'sets an expiration date on create' do
    expect(token.expires_at).not_to be_nil
  end

  it 'has the correct length token' do
    expect(token.new_token.bytes.length).to eq(32)
  end

  it 'validates expires_at', :aggregate_failures do
    token.expires_at = nil
    expect(token).not_to be_valid
    expect(token.errors.messages.to_h).to include(expires_at: ['must not be nil'])
  end

  describe '#current?' do
    it 'returns true when not expired' do
      expect(token.current?).to be(true)
    end

    it 'returns false when expired' do
      token.expires_at = Time.now - 1.second
      expect(token.current?).to be(false)
    end
  end

  describe '#expire!' do
    it 'expires the token' do
      expect { token.expire! }.to change { token.current? }.to(false)
    end
  end

  describe '#match?' do
    it 'matches with the correct token' do
      t = token.new_token
      expect(described_class.find(token.id)).to be_match(t)
    end

    it 'does not match with an invalid token' do
      expect(described_class.find(token.id)).not_to be_match('invalid')
    end
  end
end
