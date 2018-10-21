# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReceiptMailer, type: :mailer do
  let(:user) { FactoryBot.create(:user) }
  let(:event) { FactoryBot.create(:event, cost: 10) }
  let(:reg) { FactoryBot.create(:registration, user: user, event: event) }
  let(:app) { FactoryBot.create(:family_application) }

  def payment(parent)
    FactoryBot.create(:payment, parent: parent)
  end

  def transaction_for(parent, user)
    payment(parent).sale!('fake-valid-nonce', email: user.email, user_id: user.id).transaction
  end

  # Collisions can occur between multiple simultaneous test suites. Restart any failed suites.
  let(:braintree_api_regex) { %r{POST /merchants/#{ENV['BRAINTREE_MERCHANT_ID']}/transactions 201} }

  before(:each) { generic_seo_and_ao }

  describe 'receipt' do
    describe 'registration' do
      it 'should submit the transaction successfully' do
        $receipt_email = user.email
        expect { $tr = transaction_for(reg, user) }.to output(braintree_api_regex).to_stdout_from_any_process
        expect($tr.status).to be_in(%w[submitted_for_settlement gateway_rejected])
      end

      describe 'mail' do
        let(:mail) { ReceiptMailer.receipt($tr, payment(reg)) }

        it 'renders the headers' do
          expect(mail.subject).to eql('Your receipt from Birmingham Power Squadron')
          expect(mail.to).to eql([$receipt_email])
          expect(mail.from).to eql(['receipts@bpsd9.org'])
        end

        it 'renders the body' do
          expect(mail.body.encoded).to include('Transaction Receipt')
          expect(mail.body.encoded).to include('Transaction information')
          expect(mail.body.encoded).to match(/(ending in \*\*)|(Paid via PayPal)/)
        end
      end
    end

    describe 'member application' do
      it 'should submit the transaction successfully' do
        $receipt_email = user.email
        expect { $tr = transaction_for(app, user) }.to output(braintree_api_regex).to_stdout_from_any_process
        expect($tr.status).to be_in(%w[submitted_for_settlement gateway_rejected])
      end

      describe 'mail' do
        let(:mail) { ReceiptMailer.receipt($tr, payment(app)) }

        it 'renders the headers' do
          expect(mail.subject).to eql('Your receipt from Birmingham Power Squadron')
          expect(mail.to).to eql([$receipt_email])
          expect(mail.from).to eql(['receipts@bpsd9.org'])
        end

        it 'renders the body' do
          expect(mail.body.encoded).to include('Transaction Receipt')
          expect(mail.body.encoded).to include('Transaction information')
          expect(mail.body.encoded).to match(/(ending in \*\*)|(Paid via PayPal)/)
        end
      end
    end

    describe 'dues' do
      it 'should submit the transaction successfully' do
        $receipt_email = user.email
        expect { $tr = transaction_for(user, user) }.to output(braintree_api_regex).to_stdout_from_any_process
        expect($tr.status).to be_in(%w[submitted_for_settlement gateway_rejected])
      end

      describe 'mail' do
        let(:mail) { ReceiptMailer.receipt($tr, payment(user)) }

        it 'renders the headers' do
          expect(mail.subject).to eql('Your receipt from Birmingham Power Squadron')
          expect(mail.to).to eql([$receipt_email])
          expect(mail.from).to eql(['receipts@bpsd9.org'])
        end

        it 'renders the body' do
          expect(mail.body.encoded).to include('Transaction Receipt')
          expect(mail.body.encoded).to include('Transaction information')
          expect(mail.body.encoded).to match(/(ending in \*\*)|(Paid via PayPal)/)
        end
      end
    end
  end

  describe 'paid' do
    describe 'registration' do
      let(:mail) { ReceiptMailer.paid(payment(reg)) }

      it 'renders the headers' do
        expect(mail.subject).to eql('Registration paid')
        expect(mail.to).to eql(['seo@bpsd9.org', 'aseo@bpsd9.org', 'treasurer@bpsd9.org'])
        expect(mail.from).to eql(['support@bpsd9.org'])
      end

      it 'renders the body' do
        expect(mail.body.encoded).to include('This is an automated message that was sent to')
        expect(mail.body.encoded).to include('Paid Registration')
        expect(mail.body.encoded).to include('Amount paid: $')
      end
    end

    describe 'member application' do
      let(:mail) { ReceiptMailer.paid(payment(app)) }

      it 'renders the headers' do
        expect(mail.subject).to eql('Membership application paid')
        expect(mail.to.sort).to eql([generic_seo_and_ao[:ao].user.email, generic_seo_and_ao[:seo].user.email].sort)
        expect(mail.from).to eql(['support@bpsd9.org'])
      end

      it 'renders the body' do
        expect(mail.body.encoded).to include('This is an automated message that was sent to')
        expect(mail.body.encoded).to include('Membership Application Paid')
        expect(mail.body.encoded).to include('Amount paid: $')
      end
    end

    describe 'dues' do
      let(:mail) { ReceiptMailer.paid(payment(user)) }

      it 'renders the headers' do
        expect(mail.subject).to eql('Annual dues paid')
        expect(mail.to).to eql([generic_seo_and_ao[:ao].user.email])
        expect(mail.from).to eql(['support@bpsd9.org'])
      end

      it 'renders the body' do
        expect(mail.body.encoded).to include('This is an automated message that was sent to')
        expect(mail.body.encoded).to include('Annual Dues Paid')
        expect(mail.body.encoded).to include('Amount paid: $')
      end
    end
  end
end
