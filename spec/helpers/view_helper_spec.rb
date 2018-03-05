require 'rails_helper'

RSpec.describe ViewHelper, type: :helper do
  describe 'officer flags' do
    it 'should get the correct SVG for Lt/C' do
      expect(ViewHelper.officer_flag('educational')).to include(
        '<svg ',
        '<title>LTC</title>',
        'fill="#E4002B"',
        "<path d=\"M 1536 512\nl 80 136\nl -40 -8\nl 0 896"
      )
    end

    it 'should get the correct SVG for Cdr' do
      ViewHelper.officer_flag('commander').inspect
      expect(ViewHelper.officer_flag('commander')).to include(
        '<svg ',
        '<title>CDR</title>',
        'fill="#012169"',
        "<path d=\"M 1536 512\nl 80 136\nl -40 -8\nl 0 896"
      )
    end

    it 'should get the correct SVG for 1st/Lt' do
      expect(ViewHelper.officer_flag('asst_secretary')).to include(
        '<svg ',
        '<title>1LT</title>',
        "<path d=\"M 1536 512\nl 80 136\nl -40 -8\nl 0 896"
      )
    end
  end
end
