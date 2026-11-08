# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DmarcConvert do
  let(:xml) { file_fixture('dmarc_report/pass.xml').read }

  it 'converts a report that omits adkim and aspf', :aggregate_failures do
    convert = described_class.new(xml.sub(%r{<adkim>.*?</adkim>}m, '').sub(%r{<aspf>.*?</aspf>}m, ''))

    expect(convert.to_proto.policy_published.domain).to eq('bpsd9.org')
    expect(convert).to be_success
  end

  it 'reports a parse error for a report that is not XML', :aggregate_failures do
    convert = described_class.new('this is not xml')

    expect(convert.to_proto).to be_nil
    expect(convert).not_to be_success
    expect(convert.error).to include(type: 'parse')
  end
end
