# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PersistentApiToken, type: :model do
  let(:token) { FactoryBot.create(:persistent_api_token) }

  it 'does not set an expiration date on create' do
    expect(token.expires_at).to be_nil
  end

  it 'has the correct length token' do
    expect(token.new_token.bytes.length).to eq(64)
  end

  describe 'current scope' do
    it 'does not include non-persistent tokens', :aggregate_failures do
      user = FactoryBot.create(:user)
      at = ApiToken.create(user: user)
      pat = described_class.create(user: user)
      pat_at = ApiToken.find(pat.id)

      expect(user.api_tokens.to_a).to contain_exactly(at, pat_at)
      expect(described_class.current).to contain_exactly(pat)
    end
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
    context 'when using the persistent model' do
      it 'matches with the correct token' do
        t = token.new_token
        expect(described_class.find(token.id)).to be_match(t)
      end

      it 'does not match with an invalid token' do
        expect(described_class.find(token.id)).not_to be_match('invalid')
      end
    end

    context 'when using the base model' do
      it 'matches with the correct token' do
        t = token.new_token
        expect(ApiToken.find(token.id)).to be_match(t)
      end

      it 'does not match with an invalid token' do
        expect(ApiToken.find(token.id)).not_to be_match('invalid')
      end
    end
  end
end
