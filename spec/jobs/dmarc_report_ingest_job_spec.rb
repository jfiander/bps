# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DmarcReportIngestJob do
  let(:bucket) { 'bps-dmarc-reports' }
  let(:filename) { 'google.com!bpsd9.org!1687737600!1687823999.xml' }
  let(:key) { "dmarc/validated/2023/06/26/#{filename}" }
  let(:processed_key) { "dmarc/processed/2023/06/26/#{filename}" }
  let(:xml) { file_fixture('dmarc_report/pass.xml').read }
  let(:client) { Aws::S3::Client.new(stub_responses: true) }

  before do
    allow(Aws::S3::Client).to receive(:new).and_return(client)
    allow(Resolv).to receive(:getname).and_return('e226-1.smtp-out.us-east-2.amazonses.com')

    client.stub_responses(:list_objects_v2, contents: [{ key: }])
    client.stub_responses(:get_object, body: xml)
  end

  it 'ingests each validated report and moves it to the processed prefix', :aggregate_failures do
    expect(client).to receive(:copy_object).with(hash_including(bucket:, key: processed_key)).and_call_original
    expect(client).to receive(:delete_object).with(hash_including(bucket:, key:)).and_call_original

    expect { described_class.new.perform }.to change(DmarcReport, :count).by(1)
    expect(DmarcReport.last).to have_attributes(auto: true, filename:)
  end

  it 'posts the imported report to Slack' do
    expect(SlackNotification).to receive(:new)
      .with(hash_including(channel: :notifications, title: 'DMARC Report Imported')).and_call_original

    described_class.new.perform
  end

  context 'with an already-ingested report' do
    before { create(:dmarc_report, xml:, filename: 'manual-upload.xml') }

    it 'moves it to the processed prefix without another import', :aggregate_failures do
      expect(client).to receive(:copy_object).with(hash_including(bucket:, key: processed_key)).and_call_original
      expect(client).to receive(:delete_object).with(hash_including(bucket:, key:)).and_call_original

      expect { described_class.new.perform }.not_to change(DmarcReport, :count)
    end
  end

  context 'when a report fails to ingest' do
    before { allow(DmarcReport).to receive(:create!).and_raise(StandardError, 'boom') }

    it 'raises outside production and keeps the object', :aggregate_failures do
      expect(client).not_to receive(:copy_object)
      expect(client).not_to receive(:delete_object)

      expect { described_class.new.perform }.to raise_error(StandardError, 'boom')
    end

    context 'when in production' do
      let(:bugsnag_report) { instance_double(Bugsnag::Report) }

      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
        allow(Bugsnag).to receive(:notify).with('Error ingesting DMARC report').and_yield(bugsnag_report)
      end

      it 'reports to Bugsnag and keeps the object', :aggregate_failures do
        expect(client).not_to receive(:delete_object)
        expect(bugsnag_report).to receive(:add_metadata).with(:dmarc, { key:, error: 'boom' })

        described_class.new.perform
      end
    end
  end
end
