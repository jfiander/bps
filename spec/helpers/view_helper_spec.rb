# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ViewHelper do
  describe 'officer flags' do
    it 'gets the correct SVG for Lt/C' do
      expect(described_class.officer_flag('educational')).to include(
        '<svg ',
        '<title>LTC</title>',
        '<path d="M 0 0 l 3072 0 l 0 2048 l -3072 0 l 0 -2048 z" fill="#E4002B" />',
        '<g transform="translate(-512)">'
      )
    end

    it 'gets the correct SVG for Cdr' do
      expect(described_class.officer_flag('commander')).to include(
        '<svg ',
        '<title>CDR</title>',
        '<path d="M 0 0 l 3072 0 l 0 2048 l -3072 0 l 0 -2048 z" fill="#012169" />',
        '<g transform="translate(-768, 192)">'
      )
    end

    it 'gets the correct SVG for 1st/Lt' do
      expect(described_class.officer_flag('asst_secretary')).to include(
        '<svg ',
        '<title>1LT</title>',
        '<path d="M 0 0 l 3072 0 l 0 2048 l -3072 0 l 0 -2048 z" fill="#FFFFFF" ' \
        'stroke="#000000" stroke-width="5" />'
      )
    end
  end
end
