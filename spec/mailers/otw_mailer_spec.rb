require "rails_helper"

RSpec.describe OTWMailer, type: :mailer do
  describe 'requested' do
    let(:otw) { FactoryBot.create(:otw_training_user) }
    let(:mail) { OTWMailer.requested(otw) }

    it 'renders the headers' do
      expect(mail.subject).to eql('On-the-Water training requested')
      expect(mail.to).to eql(['seo@bpsd9.org', 'aseo@bpsd9.org'])
      expect(mail.from).to eql(['support@bpsd9.org'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to include(
        'This is an automated message that was sent to'
      )
      expect(mail.body.encoded).to include('New Training Request')
      expect(mail.body.encoded).to include('Training requested')
    end
  end
end
