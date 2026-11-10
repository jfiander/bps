# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'admin/dmarc_reports/_report' do
  let(:xml) { file_fixture('dmarc_report/pass.xml').read }

  before do
    view.extend(DmarcReportsHelper)
    allow(Resolv).to receive(:getname).and_return('e226-1.smtp-out.us-east-2.amazonses.com')
  end

  def render_report(auto:)
    render(partial: 'admin/dmarc_reports/report', locals: { report: create(:dmarc_report, xml:, auto:) })
  end

  def auto_icon = Nokogiri::HTML(rendered).at_css('.org_name i.fa-calendar-clock.purple')

  it 'flags a report that was processed automatically' do
    render_report(auto: true)

    expect(auto_icon&.[]('title')).to eq('Processed automatically')
  end

  it 'does not flag a manually uploaded report' do
    render_report(auto: false)

    expect(auto_icon).to be_nil
  end
end
