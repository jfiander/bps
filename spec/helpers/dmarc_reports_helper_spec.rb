# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DmarcReportsHelper do
  describe '#dmarc_field_icon' do
    it 'generates the correct disposition icon' do
      expect(dmarc_field_icon(:disposition)).to match(' fa-share ')
    end

    it 'generates the correct dkim icon' do
      expect(dmarc_field_icon(:dkim)).to match(' fa-d ')
    end

    it 'generates the correct spf icon' do
      expect(dmarc_field_icon(:spf)).to match(' fa-s ')
    end
  end

  describe '#disposition_icon' do
    it 'generates the correct disposition icon' do
      expect(disposition_icon(:QUARANTINE)).to eq('folder-xmark')
    end
  end

  describe '#dmarc_result_icon' do
    it 'generates the correct result icon' do
      expect(dmarc_result_icon('pass')).to eq('circle-check')
    end

    it 'generates the correct result icon for a failure' do
      expect(dmarc_result_icon('fail')).to eq('octagon-xmark')
    end
  end
end
