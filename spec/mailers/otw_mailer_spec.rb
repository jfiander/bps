# frozen_string_literal: true

require 'rails_helper'

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
      expect(mail.body.encoded).to include('This is an automated message that was sent to')
      expect(mail.body.encoded).to include('New Training Request')
      expect(mail.body.encoded).to include('Training requested')
    end
  end

  describe 'jumpstart' do
    let(:options) do
      {
        name: 'John',
        email: 'nobody@example.com',
        phone: '555-555-5555',
        details: 'Boat',
        availability: 'Whenever'
      }
    end
    let(:mail) { OTWMailer.jumpstart(options) }

    context 'with details' do
      let(:mail) { OTWMailer.jumpstart(options) }

      it 'renders the headers' do
        expect(mail.subject).to eql('Jump Start training requested')
        expect(mail.to).to eql(['seo@bpsd9.org', 'aseo@bpsd9.org'])
        expect(mail.from).to eql(['support@bpsd9.org'])
      end

      it 'renders the body' do
        expect(mail.body.encoded).to include('This is an automated message that was sent to')
        expect(mail.body.encoded).to include('Jump Start Training Request')
        expect(mail.body.encoded).to include('Phone')
        expect(mail.body.encoded).to include('Boat, location, or knowledge')
        expect(mail.body.encoded).to include('Availability')
      end
    end

    context 'with only availability' do
      let(:mail) { OTWMailer.jumpstart(options.except(:phone, :details)) }

      it 'renders the headers' do
        expect(mail.subject).to eql('Jump Start training requested')
        expect(mail.to).to eql(['seo@bpsd9.org', 'aseo@bpsd9.org'])
        expect(mail.from).to eql(['support@bpsd9.org'])
      end

      it 'renders the body' do
        expect(mail.body.encoded).to include('This is an automated message that was sent to')
        expect(mail.body.encoded).to include('Jump Start Training Request')
        expect(mail.body.encoded).not_to include('Phone')
        expect(mail.body.encoded).not_to include('Boat, location, or knowledge')
        expect(mail.body.encoded).to include('Availability')
      end
    end
  end
end
