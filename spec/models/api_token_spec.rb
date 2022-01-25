# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiToken, type: :model do
  let(:token) { FactoryBot.create(:api_token) }

  it 'sets an expiration date on create' do
    expect(token.expires_at).not_to be_nil
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

  describe '#match?' do
    it 'matches with the correct token' do
      t = token.new_token
      expect(ApiToken.find(token.id)).to be_match(t)
    end

    it 'does not match with an invalid token' do
      expect(ApiToken.find(token.id)).not_to be_match('invalid')
    end
  end
end
