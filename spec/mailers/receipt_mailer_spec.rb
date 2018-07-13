# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReceiptMailer, type: :mailer do
  before(:each) do
    generic_seo_and_ao
    @user = FactoryBot.create(:user)
    event = FactoryBot.create(:event, cost: 10)
    @reg = FactoryBot.create(:registration, user: @user, event: event)
    @member_application = FactoryBot.create(:member_application, :with_primary)
  end

  describe 'receipt' do
    describe 'registration' do
      let(:mail) do
        payment = FactoryBot.create(:payment, parent: @reg)
        transaction = payment.sale!(
          'fake-valid-nonce', email: @user.email, user_id: @user.id
        ).transaction
        ReceiptMailer.receipt(transaction, payment)
      end

      it 'renders the headers' do
        expect(mail.subject).to eql('Your receipt from Birmingham Power Squadron')
        expect(mail.to).to eql([@user.email])
        expect(mail.from).to eql(['receipts@bpsd9.org'])
      end

      it 'renders the body' do
        expect(mail.body.encoded).to include('Transaction Receipt')
        expect(mail.body.encoded).to include('Transaction information')
        expect(mail.body.encoded).to match(/(ending in \*\*)|(Paid via PayPal)/)
      end
    end

    describe 'member application' do
      let(:mail) do
        payment = FactoryBot.create(:payment, parent: @member_application)
        transaction = payment.sale!(
          'fake-valid-nonce', email: @user.email, user_id: @user.id
        ).transaction
        ReceiptMailer.receipt(transaction, payment)
      end

      it 'renders the headers' do
        expect(mail.subject).to eql('Your receipt from Birmingham Power Squadron')
        expect(mail.to).to eql([@user.email])
        expect(mail.from).to eql(['receipts@bpsd9.org'])
      end

      it 'renders the body' do
        expect(mail.body.encoded).to include('Transaction Receipt')
        expect(mail.body.encoded).to include('Transaction information')
        expect(mail.body.encoded).to match(/(ending in \*\*)|(Paid via PayPal)/)
      end
    end

    describe 'dues' do
      let(:mail) do
        payment = FactoryBot.create(:payment, parent: @user)
        transaction = payment.sale!(
          'fake-valid-nonce', email: @user.email, user_id: @user.id
        ).transaction
        ReceiptMailer.receipt(transaction, payment)
      end

      it 'renders the headers' do
        expect(mail.subject).to eql('Your receipt from Birmingham Power Squadron')
        expect(mail.to).to eql([@user.email])
        expect(mail.from).to eql(['receipts@bpsd9.org'])
      end

      it 'renders the body' do
        expect(mail.body.encoded).to include('Transaction Receipt')
        expect(mail.body.encoded).to include('Transaction information')
        expect(mail.body.encoded).to match(/(ending in \*\*)|(Paid via PayPal)/)
      end
    end
  end

  describe 'paid' do
    describe 'registration' do
      let(:mail) do
        payment = FactoryBot.create(
          :payment, parent_id: @reg.id, parent_type: 'Registration'
        )
        ReceiptMailer.paid(payment)
      end

      it 'renders the headers' do
        expect(mail.subject).to eql('Registration paid')
        expect(mail.to).to eql(['seo@bpsd9.org', 'aseo@bpsd9.org'])
        expect(mail.from).to eql(['support@bpsd9.org'])
      end

      it 'renders the body' do
        expect(mail.body.encoded).to include(
          'This is an automated message that was sent to'
        )
        expect(mail.body.encoded).to include('Paid Registration')
        expect(mail.body.encoded).to include('Amount paid: $')
      end
    end

    describe 'member application' do
      let(:mail) do
        payment = FactoryBot.create(
          :payment,
          parent_id: @member_application.id, parent_type: 'MemberApplication'
        )
        ReceiptMailer.paid(payment)
      end

      it 'renders the headers' do
        expect(mail.subject).to eql('Membership application paid')
        expect(mail.to.sort).to eql(
          [
            generic_seo_and_ao[:ao].user.email,
            generic_seo_and_ao[:seo].user.email
          ].sort
        )
        expect(mail.from).to eql(['support@bpsd9.org'])
      end

      it 'renders the body' do
        expect(mail.body.encoded).to include(
          'This is an automated message that was sent to'
        )
        expect(mail.body.encoded).to include('Membership Application Paid')
        expect(mail.body.encoded).to include('Amount paid: $')
      end
    end

    describe 'dues' do
      let(:mail) do
        @user = FactoryBot.create(:user)
        payment = FactoryBot.create(
          :payment, parent_id: @user.id, parent_type: 'User'
        )
        ReceiptMailer.paid(payment)
      end

      it 'renders the headers' do
        expect(mail.subject).to eql('Annual dues paid')
        expect(mail.to).to eql([generic_seo_and_ao[:ao].user.email])
        expect(mail.from).to eql(['support@bpsd9.org'])
      end

      it 'renders the body' do
        expect(mail.body.encoded).to include(
          'This is an automated message that was sent to'
        )
        expect(mail.body.encoded).to include('Annual Dues Paid')
        expect(mail.body.encoded).to include('Amount paid: $')
      end
    end
  end
end
