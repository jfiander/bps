# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DmarcReport do
  let(:dmarc_report) { create(:dmarc_report, xml: file_fixture('dmarc_report.xml').read) }

  describe '#to_proto' do
    it 'generates the correct proto' do
      expect(dmarc_report.to_proto).to eq(
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
            np: 'reject'
          },
          record: {
            row: {
              policy_evaluated: {
                disposition: :NONE,
                dkim: 'pass',
                spf: 'pass'
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
          }
        )
      )
    end
  end
end
