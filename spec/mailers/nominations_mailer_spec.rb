# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NominationsMailer, type: :mailer do
  describe 'nomination' do
    let(:nominator) { FactoryBot.create(:user) }

    context 'with an ExCom award' do
      let(:mail) do
        NominationsMailer.nomination(
          nominator,
          'Bill Booth Moose Milk',
          'John Q Public',
          'Executive Committee'
        )
      end

      it 'renders the headers' do
        expect(mail).to contain_mail_headers(
          subject: 'Award nomination submitted',
          to: ['excom@bpsd9.org'],
          from: ['support@bpsd9.org']
        )
      end

      it 'renders the body' do
        expect(mail.body.encoded).to contain_and_match(
          'This is an automated message that was sent to',
          'Award Nomination Submitted', 'Bill Booth Moose Milk Award',
          nominator.full_name, 'John Q Public'
        )
      end
    end

    context 'with a Commander award' do
      let(:mail) do
        NominationsMailer.nomination(
          nominator,
          'Outstanding Service',
          'John Q Public',
          'Commander'
        )
      end

      it 'renders the headers' do
        expect(mail).to contain_mail_headers(
          subject: 'Award nomination submitted',
          to: ['commander@bpsd9.org'],
          from: ['support@bpsd9.org']
        )
      end

      it 'renders the body' do
        expect(mail.body.encoded).to contain_and_match(
          'This is an automated message that was sent to',
          'Award Nomination Submitted', 'Outstanding Service Award',
          nominator.full_name, 'John Q Public'
        )
      end
    end

    context 'with an SEO award' do
      let(:mail) do
        NominationsMailer.nomination(
          nominator,
          'Education',
          'John Q Public',
          'SEO'
        )
      end

      it 'renders the headers' do
        expect(mail).to contain_mail_headers(
          subject: 'Award nomination submitted',
          to: ['seo@bpsd9.org'],
          from: ['support@bpsd9.org']
        )
      end

      it 'renders the body' do
        expect(mail.body.encoded).to contain_and_match(
          'This is an automated message that was sent to',
          'Award Nomination Submitted', 'Education Award',
          nominator.full_name, 'John Q Public'
        )
      end
    end
  end
end
