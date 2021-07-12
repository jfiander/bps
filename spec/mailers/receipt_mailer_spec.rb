# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReceiptMailer, type: :mailer do
  let!(:user) { FactoryBot.create(:user) }
  let(:event) { FactoryBot.create(:event, cost: 10) }
  let(:reg) { FactoryBot.create(:registration, user: user, event: event) }
  let(:app) { FactoryBot.create(:family_application) }
  let(:generic) { FactoryBot.create(:generic_payment, email: 'nobody@example.com') }

  let(:transaction) { HashWithIndifferentAccess.new }

  before { generic_seo_and_ao }

  describe 'receipt' do
    describe 'registration' do
      describe 'mail' do
        let(:payment) { FactoryBot.create(:payment, parent: reg) }
        let(:mail) { described_class.receipt(payment, transaction) }

        it 'renders the headers' do
          expect(mail).to contain_mail_headers(
            subject: 'Your receipt from Birmingham Power Squadron',
            to: [user.email],
            from: ['receipts@bpsd9.org']
          )
        end

        it 'renders the body' do
          expect(mail.body.encoded).to contain_and_match(
            'Transaction Receipt', 'Transaction information',
            /(ending in \*\*)|(Paid via PayPal)/
          )
        end
      end
    end

    describe 'member application' do
      let(:payment) { FactoryBot.create(:payment, parent: app) }

      describe 'mail' do
        let(:mail) { described_class.receipt(payment, transaction) }

        it 'renders the headers' do
          expect(mail).to contain_mail_headers(
            subject: 'Your receipt from Birmingham Power Squadron',
            to: [user.email],
            from: ['receipts@bpsd9.org']
          )
        end

        it 'renders the body' do
          expect(mail.body.encoded).to contain_and_match(
            'Transaction Receipt', 'Transaction information',
            /(ending in \*\*)|(Paid via PayPal)/
          )
        end
      end
    end

    describe 'dues' do
      let(:payment) { FactoryBot.create(:payment, parent: user) }

      describe 'mail' do
        let(:mail) { described_class.receipt(payment, transaction) }

        it 'renders the headers' do
          expect(mail).to contain_mail_headers(
            subject: 'Your receipt from Birmingham Power Squadron',
            to: [user.email],
            from: ['receipts@bpsd9.org']
          )
        end

        it 'renders the body' do
          expect(mail.body.encoded).to contain_and_match(
            'Transaction Receipt', 'Transaction information',
            /(ending in \*\*)|(Paid via PayPal)/
          )
        end
      end
    end
  end

  describe 'paid' do
    describe 'registration' do
      let(:payment) { FactoryBot.create(:payment, parent: reg) }
      let(:mail) { described_class.paid(payment) }

      it 'renders the headers' do
        expect(mail).to contain_mail_headers(
          subject: 'Registration paid',
          to: ['seo@bpsd9.org', 'aseo@bpsd9.org', 'treasurer@bpsd9.org'],
          from: ['support@bpsd9.org']
        )
      end

      it 'renders the body' do
        expect(mail.body.encoded).to contain_and_match(
          'This is an automated message that was sent to',
          'Paid Registration', 'Amount paid: $'
        )
      end
    end

    describe 'member application' do
      let(:payment) { FactoryBot.create(:payment, parent: app) }
      let(:mail) { described_class.paid(payment) }

      it 'renders the headers' do
        expect(mail).to contain_mail_headers(
          subject: 'Membership application paid',
          to: [generic_seo_and_ao[:ao].user.email, generic_seo_and_ao[:seo].user.email].sort,
          from: ['support@bpsd9.org']
        )
      end

      it 'renders the body' do
        expect(mail.body.encoded).to contain_and_match(
          'This is an automated message that was sent to',
          'Membership Application Paid', 'Amount paid: $'
        )
      end
    end

    describe 'dues' do
      let(:payment) { FactoryBot.create(:payment, parent: user) }
      let(:mail) { described_class.paid(payment) }

      it 'renders the headers' do
        expect(mail).to contain_mail_headers(
          subject: 'Annual dues paid',
          to: [generic_seo_and_ao[:ao].user.email],
          from: ['support@bpsd9.org']
        )
      end

      it 'renders the body' do
        expect(mail.body.encoded).to contain_and_match(
          'This is an automated message that was sent to',
          'Annual Dues Paid', 'Amount paid: $'
        )
      end
    end

    describe 'generic payment' do
      let(:payment) { FactoryBot.create(:payment, parent: generic) }
      let(:mail) { described_class.paid(payment) }

      it 'renders the headers' do
        expect(mail).to contain_mail_headers(
          subject: 'Payment received',
          to: ['treasurer@bpsd9.org', 'webmaster@bpsd9.org'].sort,
          from: ['support@bpsd9.org']
        )
      end

      it 'renders the body' do
        expect(mail.body.encoded).to contain_and_match(
          'Someone has submitted a payment.'
        )
      end
    end
  end
end
