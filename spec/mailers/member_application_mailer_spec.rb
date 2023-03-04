# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MemberApplicationMailer do
  let(:single_application) { create(:single_application) }
  let(:family_application) { create(:family_application) }

  before { generic_seo_and_ao }

  context 'with a single application' do
    describe 'new_application' do
      let(:mail) { described_class.new_application(single_application) }

      it 'renders the headers' do
        expect(mail).to contain_mail_headers(
          subject: 'New member application',
          to: [generic_seo_and_ao[:seo].user.email, generic_seo_and_ao[:ao].user.email],
          from: ['support@bpsd9.org']
        )
      end

      it 'renders the body' do
        expect(mail.body.encoded).to contain_and_match(
          'This is an automated message that was sent to',
          'Membership Application', 'ExCom', 'Primary Applicant'
        )
        expect(mail.body.encoded).not_to include('Additional Applicant #')
      end
    end

    describe 'confirm' do
      let(:mail) { described_class.confirm(single_application) }

      it 'renders the headers' do
        expect(mail).to contain_mail_headers(
          subject: 'Member application received!',
          to: [single_application.primary.email],
          from: ['ao@bpsd9.org']
        )
      end

      it 'renders the body' do
        expect(mail.body.encoded).to contain_and_match('You have successfully applied', 'will review your application')
        expect(mail.body.encoded).not_to include('yourself')
      end
    end

    describe 'approved' do
      let(:mail) { described_class.approved(single_application) }

      it 'renders the headers' do
        expect(mail).to contain_mail_headers(
          subject: 'Member application approved!',
          to: [single_application.primary.email],
          from: ['ao@bpsd9.org']
        )
      end

      it 'renders the body' do
        expect(mail.body.encoded).to contain_and_match('Welcome Aboard!', 'You are now a member')
        expect(mail.body.encoded).not_to include('are now members')
      end
    end

    describe 'approval_notice' do
      let(:mail) { described_class.approval_notice(single_application) }

      it 'renders the headers' do
        expect(mail).to contain_mail_headers(
          subject: 'Member application approved',
          to: [generic_seo_and_ao[:seo].user.email, generic_seo_and_ao[:ao].user.email],
          from: ['support@bpsd9.org']
        )
      end

      it 'renders the body' do
        expect(mail.body.encoded).to contain_and_match('Membership Application Approved', 'Primary Applicant')
        expect(mail.body.encoded).not_to include('Additional Applicant #')
      end
    end

    describe 'paid' do
      let(:mail) { described_class.paid(single_application) }

      it 'renders the headers' do
        expect(mail).to contain_mail_headers(
          subject: 'Membership application paid',
          to: [generic_seo_and_ao[:seo].user.email, generic_seo_and_ao[:ao].user.email],
          from: ['support@bpsd9.org']
        )
      end

      it 'renders the body' do
        expect(mail.body.encoded).to contain_and_match('Membership Application Paid', 'Primary Applicant')
      end
    end

    describe 'paid_dues' do
      let(:user) { create(:user) }
      let(:mail) { described_class.paid_dues(user) }

      it 'renders the headers' do
        expect(mail).to contain_mail_headers(
          subject: 'Annual dues paid',
          to: [generic_seo_and_ao[:ao].user.email],
          from: ['support@bpsd9.org']
        )
      end

      it 'renders the body' do
        expect(mail.body.encoded).to contain_and_match('Annual Dues Paid', 'Member information')
      end
    end
  end

  context 'with a family application' do
    describe 'new_application' do
      let(:mail) { described_class.new_application(family_application) }

      it 'renders the headers' do
        expect(mail).to contain_mail_headers(
          subject: 'New member application',
          to: [generic_seo_and_ao[:seo].user.email, generic_seo_and_ao[:ao].user.email],
          from: ['support@bpsd9.org']
        )
      end

      it 'renders the body' do
        expect(mail.body.encoded).to contain_and_match(
          'This is an automated message that was sent to', 'Membership Application', 'ExCom',
          'Primary Applicant', 'Additional Applicant #'
        )
      end
    end

    describe 'confirm' do
      let(:mail) { described_class.confirm(family_application) }

      it 'renders the headers' do
        expect(mail).to contain_mail_headers(
          subject: 'Member application received!',
          to: [family_application.primary.email],
          from: ['ao@bpsd9.org']
        )
      end

      it 'renders the body' do
        expect(mail.body.encoded).to contain_and_match(
          'You have successfully applied', 'yourself', 'will review your application'
        )
      end
    end

    describe 'approved' do
      let(:mail) { described_class.approved(family_application) }

      it 'renders the headers' do
        expect(mail).to contain_mail_headers(
          subject: 'Member application approved!',
          to: [family_application.primary.email],
          from: ['ao@bpsd9.org']
        )
      end

      it 'renders the body' do
        expect(mail.body.encoded).to contain_and_match('Welcome Aboard!', 'are now members')
        expect(mail.body.encoded).not_to include('You are now a member')
      end
    end

    describe 'approval_notice' do
      let(:mail) { described_class.approval_notice(family_application) }

      it 'renders the headers' do
        expect(mail).to contain_mail_headers(
          subject: 'Member application approved',
          to: [generic_seo_and_ao[:seo].user.email, generic_seo_and_ao[:ao].user.email],
          from: ['support@bpsd9.org']
        )
      end

      it 'renders the body' do
        expect(mail.body.encoded).to contain_and_match(
          'Membership Application Approved', 'Primary Applicant', 'Additional Applicant #'
        )
      end
    end
  end
end
