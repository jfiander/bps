# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DmarcReport do
  def create_report(name)
    create(:dmarc_report, xml: file_fixture("dmarc_report/#{name}.xml").read)
  end

  describe '#check_report_uniqueness' do
    it 'rejects duplicate reports' do
      create_report(:pass)

      expect { create_report(:pass) }.to raise_error(
        ActiveRecord::RecordInvalid, 'Validation failed: Duplicate report'
      )
    end
  end

  describe '#sources_proto' do
    let(:report) { build(:dmarc_report, xml: file_fixture('dmarc_report/pass.xml').read) }
    let(:ip) { '23.251.226.1' }
    let(:dns) { 'e226-1.smtp-out.us-east-2.amazonses.com' }

    before { allow(report).to receive(:reverse_dns).with(ip).and_return(dns) }

    it 'generates the correct sources proto' do
      report.save!

      expect(report.sources_proto).to eq(
        Dmarc::SourcesSummary.new(
          sources: [
            { source_ip: ip, dns: dns, sender: :AMAZON }
          ]
        )
      )
    end
  end

  context 'with a passing report' do
    it 'generates the correct proto' do
      expect(create_report(:pass).proto).to eq(
        Dmarc::Feedback.new(
          report_metadata: {
            org_name: 'google.com',
            email: 'noreply-dmarc-support@google.com',
            extra_contact_info: 'https://support.google.com/a/answer/2466580',
            report_id: '00000000000000000001',
            date_range: {
              begin: 1687737600, # rubocop:disable Style/NumericLiterals
              end: 1687823999 # rubocop:disable Style/NumericLiterals
            }
          },
          policy_published: {
            domain: 'bpsd9.org',
            adkim: :R,
            aspf: :R,
            p: :REJECT,
            sp: :REJECT,
            pct: 100,
            np: :REJECT
          },
          records: [{
            row: {
              source_ip: '23.251.226.1',
              count: 1,
              policy_evaluated: {
                disposition: :NONE,
                dkim: :PASS,
                spf: :PASS
              }
            },
            identifiers: {
              header_from: 'bpsd9.org'
            },
            auth_results: {
              dkim: [
                {
                  domain: 'bpsd9.org',
                  result: :PASS,
                  selector: '7h2g3540927g65h03275690g37h29056'
                },
                {
                  domain: 'amazonses.com',
                  result: :PASS,
                  selector: 'e57h069g7349w0g67036g5h730296hg7'
                }
              ],
              spf: [
                {
                  domain: 'smtp.bpsd9.org',
                  result: :PASS
                }
              ]
            }
          }]
        )
      )
    end
  end

  context 'with a failing report' do
    it 'generates the correct proto' do
      expect(create_report(:fail).proto).to eq(
        Dmarc::Feedback.new(
          report_metadata: {
            org_name: 'google.com',
            email: 'noreply-dmarc-support@google.com',
            extra_contact_info: 'https://support.google.com/a/answer/2466580',
            report_id: '00000000000000000002',
            date_range: {
              begin: 1687737600, # rubocop:disable Style/NumericLiterals
              end: 1687823999 # rubocop:disable Style/NumericLiterals
            }
          },
          policy_published: {
            domain: 'bpsd9.org',
            adkim: :R,
            aspf: :R,
            p: :REJECT,
            sp: :REJECT,
            pct: 100
          },
          records: [{
            row: {
              source_ip: '23.251.226.1',
              count: 1,
              policy_evaluated: {
                disposition: :NONE,
                dkim: :FAIL,
                spf: :FAIL,
                reason: {
                  type: :OTHER,
                  comment: 'This is a demo failure report.'
                }
              }
            },
            identifiers: {
              header_from: 'bpsd9.org'
            },
            auth_results: {
              dkim: [
                {
                  domain: 'bpsd9.org',
                  result: :FAIL,
                  selector: '7h2g3540927g65h03275690g37h29056'
                },
                {
                  domain: 'amazonses.com',
                  result: :FAIL,
                  selector: 'e57h069g7349w0g67036g5h730296hg7'
                }
              ],
              spf: [
                {
                  domain: 'smtp.bpsd9.org',
                  result: :FAIL,
                  scope: :MFROM
                }
              ]
            }
          }]
        )
      )
    end
  end
end
