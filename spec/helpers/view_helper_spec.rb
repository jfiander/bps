# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ViewHelper do
  describe 'officer flags' do
    it 'gets the correct SVG for Lt/C' do
      expect(described_class.officer_flag('educational')).to include(
        '<svg ',
        '<title>LTC</title>',
        '<path d="M 0 0 l 384 0 l 0 256 l -384 0 l 0 -256 z" fill="#E4002B" stroke="none" />',
        '<g transform="translate(-64)" stroke="none">'
      )
    end

    it 'gets the correct SVG for Cdr' do
      described_class.officer_flag('commander').inspect
      expect(described_class.officer_flag('commander')).to include(
        '<svg ',
        '<title>CDR</title>',
        '<path d="M 0 0 l 384 0 l 0 256 l -384 0 l 0 -256 z" fill="#012169" stroke="none" />',
        '<g transform="translate(-96, 24)" stroke="none">'
      )
    end

    it 'gets the correct SVG for 1st/Lt' do
      expect(described_class.officer_flag('asst_secretary')).to include(
        '<svg ',
        '<title>1LT</title>',
        '<path d="M 0 0 l 384 0 l 0 256 l -384 0 l 0 -256 z" fill="#FFFFFF" ' \
        'stroke="#000000" stroke-width="1" />'
      )
    end
  end
end
