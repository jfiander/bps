# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DmarcReportsHelper do
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
