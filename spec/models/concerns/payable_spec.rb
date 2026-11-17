# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payable do
  describe '#payment_amount' do
    it 'has no amount for a model that does not define one' do
      expect(build(:album).payment_amount).to be_nil
    end
  end
end
