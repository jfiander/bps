# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OTWMailer do
  describe 'requested' do
    let(:otw) { create(:otw_training_user) }
    let(:mail) { described_class.requested(otw) }

    it 'renders the headers' do
      expect(mail).to contain_mail_headers(
        subject: 'On-the-Water training requested',
        to: ['seo@bpsd9.org', 'aseo@bpsd9.org'],
        from: ['support@bpsd9.org']
      )
    end

    it 'renders the body' do
      expect(mail.body.encoded).to contain_and_match(
        'This is an automated message that was sent to',
        'New Training Request', 'Training requested'
      )
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
    let(:mail) { described_class.jumpstart(options) }

    context 'with details' do
      let(:mail) { described_class.jumpstart(options) }

      it 'renders the headers' do
        expect(mail).to contain_mail_headers(
          subject: 'Jump Start training requested',
          to: ['seo@bpsd9.org', 'aseo@bpsd9.org'],
          from: ['support@bpsd9.org']
        )
      end

      it 'renders the body' do
        expect(mail.body.encoded).to contain_and_match(
          'This is an automated message that was sent to',
          'Jump Start Training Request',
          'Phone', 'Boat, location, or knowledge', 'Availability'
        )
      end
    end

    context 'with only availability' do
      let(:mail) { described_class.jumpstart(options.except(:phone, :details)) }

      it 'renders the headers' do
        expect(mail).to contain_mail_headers(
          subject: 'Jump Start training requested',
          to: ['seo@bpsd9.org', 'aseo@bpsd9.org'],
          from: ['support@bpsd9.org']
        )
      end

      it 'renders the body' do
        expect(mail.body.encoded).to contain_and_match(
          'This is an automated message that was sent to',
          'Jump Start Training Request',
          'Availability'
        )
        expect(mail.body.encoded).not_to include('Phone')
        expect(mail.body.encoded).not_to include('Boat, location, or knowledge')
      end
    end
  end
end
