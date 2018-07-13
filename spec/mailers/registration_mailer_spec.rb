# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RegistrationMailer, type: :mailer do
  let(:ed_user_reg) { FactoryBot.create(:registration, :with_user) }
  let(:ed_email_reg) { FactoryBot.create(:registration, :with_email) }
  let(:event_user_reg) { FactoryBot.create(:event_registration, :with_user) }
  let(:event_email_reg) { FactoryBot.create(:event_registration, :with_email) }

  context 'with user' do
    before(:each) do
      @seo = FactoryBot.create(:bridge_office, office: 'educational')
      @ao = FactoryBot.create(:bridge_office, office: 'administrative')
    end

    describe 'registered' do
      let(:mail) { RegistrationMailer.registered(ed_user_reg) }

      it 'renders the headers' do
        expect(mail.subject).to eql('New registration')
        expect(mail.to).to eql(['seo@bpsd9.org', 'aseo@bpsd9.org'])
        expect(mail.from).to eql(['support@bpsd9.org'])
      end

      it 'renders the body' do
        expect(mail.body.encoded).to include(
          'This is an automated message that was sent to'
        )
        expect(mail.body.encoded).to include('New Registration')
        expect(mail.body.encoded).to include('Registration information')
        expect(mail.body.encoded).to include('Registrant information')
        expect(mail.body.encoded).to include(
          'please reach out to this registrant'
        )
      end
    end

    describe 'registered (event)' do
      let(:mail) { RegistrationMailer.registered(event_user_reg) }

      it 'renders the headers' do
        expect(mail.subject).to eql('New registration')
        expect(mail.to).to eql(['ao@bpsd9.org'])
        expect(mail.from).to eql(['support@bpsd9.org'])
      end

      it 'renders the body' do
        expect(mail.body.encoded).to include(
          'This is an automated message that was sent to'
        )
        expect(mail.body.encoded).to include('New Registration')
        expect(mail.body.encoded).to include('Registration information')
        expect(mail.body.encoded).to include('Registrant information')
        expect(mail.body.encoded).to include(
          'please reach out to this registrant'
        )
      end
    end

    describe 'cancelled' do
      let(:mail) { RegistrationMailer.cancelled(ed_user_reg) }

      it 'renders the headers' do
        expect(mail.subject).to eql('Cancelled registration')
        expect(mail.to).to eql(['seo@bpsd9.org', 'aseo@bpsd9.org'])
        expect(mail.from).to eql(['support@bpsd9.org'])
      end

      it 'renders the body' do
        expect(mail.body.encoded).to include(
          'This is an automated message that was sent to'
        )
        expect(mail.body.encoded).to include('Cancelled Registration')
        expect(mail.body.encoded).to include('Registration information')
        expect(mail.body.encoded).to include('Registrant information')
      end
    end

    describe 'confirm' do
      let(:mail) { RegistrationMailer.confirm(ed_user_reg) }

      it 'renders the headers' do
        expect(mail.subject).to eql('Registration confirmation')
        expect(mail.to).to eql([ed_user_reg.user.email])
        expect(mail.from).to eql(['seo@bpsd9.org'])
      end

      it 'renders the body' do
        expect(mail.body.encoded).to include('This is your confirmation')
        expect(mail.body.encoded).to include('Registration information')
        expect(mail.body.encoded).to include('If you have any questions')
        expect(mail.body.encoded).to include('You can also cancel')
        expect(mail.body.encoded).to include('Educational Officer')
      end
    end

    describe 'confirm (event)' do
      let(:mail) { RegistrationMailer.confirm(event_user_reg) }

      it 'renders the headers' do
        expect(mail.subject).to eql('Registration confirmation')
        expect(mail.to).to eql([event_user_reg.user.email])
        expect(mail.from).to eql(['ao@bpsd9.org'])
      end

      it 'renders the body' do
        expect(mail.body.encoded).to include('This is your confirmation')
        expect(mail.body.encoded).to include('Registration information')
        expect(mail.body.encoded).to include('If you have any questions')
        expect(mail.body.encoded).to include('You can also cancel')
        expect(mail.body.encoded).to include('Administrative Officer')
      end
    end
  end

  context 'with email' do
    before(:each) do
      @seo = FactoryBot.create(:bridge_office, office: 'educational')
      @ao = FactoryBot.create(:bridge_office, office: 'administrative')
    end

    describe 'registered' do
      let(:mail) { RegistrationMailer.registered(ed_email_reg) }

      it 'renders the headers' do
        expect(mail.subject).to eql('New registration')
        expect(mail.to).to eql(['seo@bpsd9.org', 'aseo@bpsd9.org'])
        expect(mail.from).to eql(['support@bpsd9.org'])
      end

      it 'renders the body' do
        expect(mail.body.encoded).to include(
          'This is an automated message that was sent to'
        )
        expect(mail.body.encoded).to include('New Registration')
        expect(mail.body.encoded).to include('Registration information')
        expect(mail.body.encoded).to include('Registrant information')
        expect(mail.body.encoded).to include(
          'please reach out to this registrant'
        )
      end
    end

    describe 'cancelled' do
      let(:mail) { RegistrationMailer.cancelled(ed_email_reg) }

      it 'renders the headers' do
        expect(mail.subject).to eql('Cancelled registration')
        expect(mail.to).to eql(['seo@bpsd9.org', 'aseo@bpsd9.org'])
        expect(mail.from).to eql(['support@bpsd9.org'])
      end

      it 'renders the body' do
        expect(mail.body.encoded).to include(
          'This is an automated message that was sent to'
        )
        expect(mail.body.encoded).to include('Cancelled Registration')
        expect(mail.body.encoded).to include('Registration information')
        expect(mail.body.encoded).to include('Registrant information')
      end
    end

    describe 'confirm' do
      let(:mail) { RegistrationMailer.confirm(ed_email_reg) }

      it 'renders the headers' do
        expect(mail.subject).to eql('Registration confirmation')
        expect(mail.to).to eql([ed_email_reg.email])
        expect(mail.from).to eql(['seo@bpsd9.org'])
      end

      it 'renders the body' do
        expect(mail.body.encoded).to include('This is your confirmation')
        expect(mail.body.encoded).to include('Registration information')
        expect(mail.body.encoded).to include('If you have any questions')
        expect(mail.body.encoded).not_to include('You can also cancel')
        expect(mail.body.encoded).to include('Educational Officer')
      end
    end

    describe 'remind' do
      let(:mail) { RegistrationMailer.remind(ed_email_reg) }

      it 'renders the headers' do
        expect(mail.subject).to eql('Registration reminder')
        expect(mail.to).to eql([ed_email_reg.email])
        expect(mail.from).to eql(['seo@bpsd9.org'])
      end

      it 'renders the body' do
        expect(mail.body.encoded).to include('This is a quick reminder')
        expect(mail.body.encoded).to include('Registration information')
        expect(mail.body.encoded).to include('If you have any questions')
        expect(mail.body.encoded).not_to include('You can also cancel')
        expect(mail.body.encoded).to include('Educational Officer')
      end
    end
  end
end
