# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RegistrationMailer, type: :mailer do
  let(:ed_user_reg) { FactoryBot.create(:registration, :with_user) }
  let(:ed_email_reg) { FactoryBot.create(:registration, :with_email) }
  let(:event_user_reg) { FactoryBot.create(:event_registration, :with_user) }
  let(:event_email_reg) { FactoryBot.create(:event_registration, :with_email) }

  before { generic_seo_and_ao }

  context 'with user' do
    describe 'registered' do
      let(:mail) { RegistrationMailer.registered(ed_user_reg) }

      it 'renders the headers' do
        expect(mail).to contain_mail_headers(
          subject: 'New registration',
          to: ['seo@bpsd9.org', 'aseo@bpsd9.org'],
          from: ['support@bpsd9.org']
        )
      end

      it 'renders the body' do
        expect(mail.body.encoded).to contain_and_match(
          'This is an automated message that was sent to',
          'New Registration', 'Registration information', 'Registrant information',
          'please reach out to this registrant'
        )
      end
    end

    describe 'registered (event)' do
      let(:mail) { RegistrationMailer.registered(event_user_reg) }

      it 'renders the headers' do
        expect(mail).to contain_mail_headers(
          subject: 'New registration',
          to: ['ao@bpsd9.org'],
          from: ['support@bpsd9.org']
        )
      end

      it 'renders the body' do
        expect(mail.body.encoded).to contain_and_match(
          'This is an automated message that was sent to',
          'New Registration', 'Registration information', 'Registrant information',
          'please reach out to this registrant'
        )
      end
    end

    describe 'cancelled' do
      let(:mail) { RegistrationMailer.cancelled(ed_user_reg) }

      it 'renders the headers' do
        expect(mail).to contain_mail_headers(
          subject: 'Cancelled registration',
          to: ['seo@bpsd9.org', 'aseo@bpsd9.org'],
          from: ['support@bpsd9.org']
        )
      end

      it 'renders the body' do
        expect(mail.body.encoded).to contain_and_match(
          'This is an automated message that was sent to',
          'Cancelled Registration', 'Registration information', 'Registrant information'
        )
      end
    end

    describe 'confirm' do
      let(:mail) { RegistrationMailer.confirm(ed_user_reg) }

      it 'renders the headers' do
        expect(mail).to contain_mail_headers(
          subject: 'Registration confirmation',
          to: [ed_user_reg.user.email],
          from: ['seo@bpsd9.org']
        )
      end

      it 'renders the body' do
        expect(mail.body.encoded).to contain_and_match(
          'This is your confirmation', 'Registration information',
          'If you have any questions', 'You can also cancel',
          'Educational Officer'
        )
      end
    end

    describe 'confirm (event)' do
      let(:mail) { RegistrationMailer.confirm(event_user_reg) }

      it 'renders the headers' do
        expect(mail).to contain_mail_headers(
          subject: 'Registration confirmation',
          to: [event_user_reg.user.email],
          from: ['ao@bpsd9.org']
        )
      end

      it 'renders the body' do
        expect(mail.body.encoded).to contain_and_match(
          'This is your confirmation', 'Registration information',
          'If you have any questions', 'You can also cancel',
          'Administrative Officer'
        )
      end
    end

    describe 'paid' do
      let(:mail) { RegistrationMailer.paid(event_user_reg) }

      it 'renders the headers' do
        expect(mail).to contain_mail_headers(
          subject: 'Registration paid',
          to: ['ao@bpsd9.org', 'treasurer@bpsd9.org'],
          from: ['support@bpsd9.org']
        )
      end

      it 'renders the body' do
        expect(mail.body.encoded).to contain_and_match('Paid Registration', 'Amount paid: $')
      end
    end

    describe 'request_schedule' do
      let(:mail) { RegistrationMailer.request_schedule(ed_user_reg.event.event_type) }

      it 'renders the headers' do
        expect(mail).to contain_mail_headers(
          subject: 'Educational request',
          to: ['seo@bpsd9.org', 'aseo@bpsd9.org'],
          from: ['support@bpsd9.org']
        )
      end

      it 'renders the body' do
        expect(mail.body.encoded).to contain_and_match(
          'Educational Request', 'has requested a', 'Please consider including this'
        )
      end
    end
  end

  context 'with email' do
    describe 'registered' do
      let(:mail) { RegistrationMailer.registered(ed_email_reg) }

      it 'renders the headers' do
        expect(mail).to contain_mail_headers(
          subject: 'New registration',
          to: ['seo@bpsd9.org', 'aseo@bpsd9.org'],
          from: ['support@bpsd9.org']
        )
      end

      it 'renders the body' do
        expect(mail.body.encoded).to contain_and_match(
          'This is an automated message that was sent to',
          'New Registration', 'Registration information', 'Registrant information',
          'please reach out to this registrant'
        )
      end
    end

    describe 'cancelled' do
      let(:mail) { RegistrationMailer.cancelled(ed_email_reg) }

      it 'renders the headers' do
        expect(mail).to contain_mail_headers(
          subject: 'Cancelled registration',
          to: ['seo@bpsd9.org', 'aseo@bpsd9.org'],
          from: ['support@bpsd9.org']
        )
      end

      it 'renders the body' do
        expect(mail.body.encoded).to contain_and_match(
          'This is an automated message that was sent to',
          'Cancelled Registration', 'Registration information', 'Registrant information'
        )
      end
    end

    describe 'confirm' do
      let(:mail) { RegistrationMailer.confirm(ed_email_reg) }

      it 'renders the headers' do
        expect(mail).to contain_mail_headers(
          subject: 'Registration confirmation',
          to: [ed_email_reg.email],
          from: ['seo@bpsd9.org']
        )
      end

      it 'renders the body' do
        expect(mail.body.encoded).to contain_and_match(
          'This is your confirmation', 'Registration information',
          'If you have any questions', 'Educational Officer'
        )
        expect(mail.body.encoded).not_to include('You can also cancel')
      end
    end

    describe 'remind' do
      let(:mail) { RegistrationMailer.remind(ed_email_reg) }

      it 'renders the headers' do
        expect(mail).to contain_mail_headers(
          subject: 'Registration reminder',
          to: [ed_email_reg.email],
          from: ['seo@bpsd9.org']
        )
      end

      it 'renders the body' do
        expect(mail.body.encoded).to contain_and_match(
          'This is a quick reminder', 'Registration information',
          'If you have any questions', 'Educational Officer'
        )
        expect(mail.body.encoded).not_to include('You can also cancel')
      end
    end
  end
end
