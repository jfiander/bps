# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ViewHelper, type: :helper do
  describe 'officer flags' do
    it 'gets the correct SVG for Lt/C' do
      expect(ViewHelper.officer_flag('educational')).to include(
        '<svg ',
        '<title>LTC</title>',
        'fill="#E4002B"',
        "<path d=\"M 1536 512\nl 80 184\nl -40 -24\nl 0 864"
      )
    end

    it 'gets the correct SVG for Cdr' do
      ViewHelper.officer_flag('commander').inspect
      expect(ViewHelper.officer_flag('commander')).to include(
        '<svg ',
        '<title>CDR</title>',
        'fill="#012169"',
        "<path d=\"M 1536 512\nl 80 184\nl -40 -24\nl 0 864"
      )
    end

    it 'gets the correct SVG for 1st/Lt' do
      expect(ViewHelper.officer_flag('asst_secretary')).to include(
        '<svg ',
        '<title>1LT</title>',
        "<path d=\"M 1536 512\nl 80 184\nl -40 -24\nl 0 864"
      )
    end
  end
end
