# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RegistrationMailer do
  let(:ed_user_reg) { create(:registration, :with_user) }
  let(:ed_email_reg) { create(:registration, :with_email) }
  let(:event_user_reg) { create(:event_registration, :with_user) }
  let(:event_email_reg) { create(:event_registration, :with_email) }

  before { generic_seo_and_ao }

  context 'with user' do
    describe 'registered' do
      let(:mail) { described_class.registered(ed_user_reg) }

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
      let(:mail) { described_class.registered(event_user_reg) }

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

    describe 'registered (rendezvous)' do
      let(:event_user_reg) { create(:event_registration, :with_user) }
      let(:rendezvous_chair) { Committee.create(department: :administrative, name: 'Rendezvous', user: create(:user)) }
      let(:mail) { described_class.registered(event_user_reg) }

      before do
        rendezvous_chair
        event_user_reg.event.event_type.update(title: 'rendezvous')
      end

      it 'renders the headers' do
        expect(mail).to contain_mail_headers(
          subject: 'New registration',
          to: ['ao@bpsd9.org', rendezvous_chair.user.email],
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

    describe 'registered (event with committee set)' do
      let(:mail) { described_class.registered(event_user_reg.reload) }
      let(:user) { create(:user, email: 'something@example.com') }
      let(:bridge) { create(:bridge_office, office: 'executive') }
      let(:committee) { create(:committee, department: 'executive', user: user) }

      before { event_user_reg.event.event_type.assign(committee.name) }

      it 'renders the headers' do
        expect(mail).to contain_mail_headers(
          subject: 'New registration',
          to: ['ao@bpsd9.org', bridge.email, committee.user.email],
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
      let(:mail) { described_class.cancelled(ed_user_reg) }

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
      let(:mail) { described_class.confirm(ed_user_reg) }

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

    describe 'advance_payment' do
      let(:mail) { described_class.advance_payment(ed_user_reg) }

      before { ed_user_reg.event.update(advance_payment: true, cost: 5) }

      it 'renders the headers' do
        expect(mail).to contain_mail_headers(
          subject: 'Registration pending',
          to: [ed_user_reg.user.email],
          from: ['seo@bpsd9.org']
        )
      end

      it 'renders the body' do
        expect(mail.html_part.body.decoded).to contain_and_match(
          'which requires advance payment', 'Registration information',
          'If you have any questions', 'You can also cancel',
          'Educational Officer'
        )
      end
    end

    describe 'confirm (event)' do
      let(:mail) { described_class.confirm(event_user_reg) }

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

      context 'with a commander and no AO' do
        before do
          ao = BridgeOffice.find_by(office: 'administrative')
          ao.update(office: 'commander', user: create(:user))
        end

        it 'renders the headers' do
          expect(mail).to contain_mail_headers(
            subject: 'Registration confirmation',
            to: [event_user_reg.user.email],
            from: ['cdr@bpsd9.org']
          )
        end

        it 'renders the body' do
          expect(mail.body.encoded).to contain_and_match(
            'This is your confirmation', 'Registration information',
            'If you have any questions', 'You can also cancel',
            'Commander'
          )
        end
      end
    end

    describe 'paid' do
      let(:mail) { described_class.paid(event_user_reg) }

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
      let(:mail) { described_class.request_schedule(ed_user_reg.event.event_type) }

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
      let(:mail) { described_class.registered(ed_email_reg) }

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
      let(:mail) { described_class.cancelled(ed_email_reg) }

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
      let(:mail) { described_class.confirm(ed_email_reg) }

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
      let(:mail) { described_class.remind(ed_email_reg) }

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
