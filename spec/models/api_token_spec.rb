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
end
