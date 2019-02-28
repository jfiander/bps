# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MemberApplicationMailer, type: :mailer do
  let(:single_application) { FactoryBot.create(:single_application) }
  let(:family_application) { FactoryBot.create(:family_application) }
  before(:each) { generic_seo_and_ao }

  context 'single application' do
    describe 'new_application' do
      let(:mail) { MemberApplicationMailer.new_application(single_application) }

      it 'renders the headers' do
        expect(mail.subject).to eql('New member application')
        expect(mail.to).to eql([generic_seo_and_ao[:seo].user.email, generic_seo_and_ao[:ao].user.email])
        expect(mail.from).to eql(['support@bpsd9.org'])
      end

      it 'renders the body' do
        expect(mail.body.encoded).to include('This is an automated message that was sent to')
        expect(mail.body.encoded).to include('Membership Application')
        expect(mail.body.encoded).to include('ExCom')
        expect(mail.body.encoded).to include('Primary Applicant')
        expect(mail.body.encoded).not_to include('Additional Applicant #')
      end
    end

    describe 'confirm' do
      let(:mail) { MemberApplicationMailer.confirm(single_application) }

      it 'renders the headers' do
        expect(mail.subject).to eql('Member application received!')
        expect(mail.to).to eql([single_application.primary.email])
        expect(mail.from).to eql(['ao@bpsd9.org'])
      end

      it 'renders the body' do
        expect(mail.body.encoded).to include('You have successfully applied')
        expect(mail.body.encoded).not_to include('yourself')
        expect(mail.body.encoded).to include('will review your application')
      end
    end

    describe 'approved' do
      let(:mail) { MemberApplicationMailer.approved(single_application) }

      it 'renders the headers' do
        expect(mail.subject).to eql('Member application approved!')
        expect(mail.to).to eql([single_application.primary.email])
        expect(mail.from).to eql(['ao@bpsd9.org'])
      end

      it 'renders the body' do
        expect(mail.body.encoded).to include('Welcome Aboard!')
        expect(mail.body.encoded).not_to include('are now members')
        expect(mail.body.encoded).to include('You are now a member')
      end
    end

    describe 'approval_notice' do
      let(:mail) { MemberApplicationMailer.approval_notice(single_application) }

      it 'renders the headers' do
        expect(mail.subject).to eql('Member application approved')
        expect(mail.to).to eql([generic_seo_and_ao[:seo].user.email, generic_seo_and_ao[:ao].user.email])
        expect(mail.from).to eql(['support@bpsd9.org'])
      end

      it 'renders the body' do
        expect(mail.body.encoded).to include('Membership Application Approved')
        expect(mail.body.encoded).to include('Primary Applicant')
        expect(mail.body.encoded).not_to include('Additional Applicant #')
      end
    end

    describe 'paid' do
      let(:mail) { MemberApplicationMailer.paid(single_application) }

      it 'renders the headers' do
        expect(mail.subject).to eql('Membership application paid')
        expect(mail.to).to eql([generic_seo_and_ao[:seo].user.email, generic_seo_and_ao[:ao].user.email])
        expect(mail.from).to eql(['support@bpsd9.org'])
      end

      it 'renders the body' do
        expect(mail.body.encoded).to include('Membership Application Paid')
        expect(mail.body.encoded).to include('Primary Applicant')
      end
    end

    describe 'paid_dues' do
      let(:user) { FactoryBot.create(:user) }
      let(:mail) { MemberApplicationMailer.paid_dues(user) }

      it 'renders the headers' do
        expect(mail.subject).to eql('Annual dues paid')
        expect(mail.to).to eql([generic_seo_and_ao[:ao].user.email])
        expect(mail.from).to eql(['support@bpsd9.org'])
      end

      it 'renders the body' do
        expect(mail.body.encoded).to include('Annual Dues Paid')
        expect(mail.body.encoded).to include('Member information')
      end
    end
  end

  context 'family application' do
    describe 'new_application' do
      let(:mail) { MemberApplicationMailer.new_application(family_application) }

      it 'renders the headers' do
        expect(mail.subject).to eql('New member application')
        expect(mail.to).to eql([generic_seo_and_ao[:seo].user.email, generic_seo_and_ao[:ao].user.email])
        expect(mail.from).to eql(['support@bpsd9.org'])
      end

      it 'renders the body' do
        expect(mail.body.encoded).to include('This is an automated message that was sent to')
        expect(mail.body.encoded).to include('Membership Application')
        expect(mail.body.encoded).to include('ExCom')
        expect(mail.body.encoded).to include('Primary Applicant')
        expect(mail.body.encoded).to include('Additional Applicant #')
      end
    end

    describe 'confirm' do
      let(:mail) { MemberApplicationMailer.confirm(family_application) }

      it 'renders the headers' do
        expect(mail.subject).to eql('Member application received!')
        expect(mail.to).to eql([family_application.primary.email])
        expect(mail.from).to eql(['ao@bpsd9.org'])
      end

      it 'renders the body' do
        expect(mail.body.encoded).to include('You have successfully applied')
        expect(mail.body.encoded).to include('yourself')
        expect(mail.body.encoded).to include('will review your application')
      end
    end

    describe 'approved' do
      let(:mail) { MemberApplicationMailer.approved(family_application) }

      it 'renders the headers' do
        expect(mail.subject).to eql('Member application approved!')
        expect(mail.to).to eql([family_application.primary.email])
        expect(mail.from).to eql(['ao@bpsd9.org'])
      end

      it 'renders the body' do
        expect(mail.body.encoded).to include('Welcome Aboard!')
        expect(mail.body.encoded).to include('are now members')
        expect(mail.body.encoded).not_to include('You are now a member')
      end
    end

    describe 'approval_notice' do
      let(:mail) { MemberApplicationMailer.approval_notice(family_application) }

      it 'renders the headers' do
        expect(mail.subject).to eql('Member application approved')
        expect(mail.to).to eql([generic_seo_and_ao[:seo].user.email, generic_seo_and_ao[:ao].user.email])
        expect(mail.from).to eql(['support@bpsd9.org'])
      end

      it 'renders the body' do
        expect(mail.body.encoded).to include('Membership Application Approved')
        expect(mail.body.encoded).to include('Primary Applicant')
        expect(mail.body.encoded).to include('Additional Applicant #')
      end
    end
  end
end
