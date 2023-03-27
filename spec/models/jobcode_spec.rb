# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Jobcode do
  let(:current_jobcode) { create(:jobcode, code: '31000', year: Time.zone.today.year) }
  let(:past_jobcode) { create(:jobcode, code: '31000', year: 1.year.ago.year) }

  describe '#current_year?' do
    it 'detects current year jobcodes' do
      expect(current_jobcode).to be_current_year
    end

    it 'detects past year jobcodes' do
      expect(past_jobcode).not_to be_current_year
    end
  end

  describe '#level' do
    it 'has the correct level' do
      expect(current_jobcode.level).to eq(:squadron)
    end
  end

  describe '#to_s' do
    it 'generates the correct string for a current jobcode' do
      expect(current_jobcode.to_s).to eq("31000\t2023\tsquadron\tCommander")
    end

    it 'generates the correct string for a past jobcode' do
      expect(past_jobcode.to_s).to eq("31000\t2022*\tsquadron\tCommander")
    end
  end
end
