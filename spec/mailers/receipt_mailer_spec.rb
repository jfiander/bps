# frozen_string_literal: true

require 'rails_helper'

def transaction_for(payment, user)
  payment.sale!('fake-valid-nonce', email: user.email, user_id: user.id).transaction
end

RSpec.describe ReceiptMailer, type: :mailer do
  let(:user) { FactoryBot.create(:user) }
  let(:event) { FactoryBot.create(:event, cost: 10) }
  let(:reg) { FactoryBot.create(:registration, user: user, event: event) }
  let(:member_application) { FactoryBot.create(:family_application) }

  let(:payment_reg) { FactoryBot.create(:payment, parent: reg) }
  let(:payment_app) { FactoryBot.create(:payment, parent: member_application) }
  let(:payment_user) { FactoryBot.create(:payment, parent: user) }

  let(:transaction_reg) { transaction_for(payment_reg, user) }
  let(:transaction_app) { transaction_for(payment_app, user) }
  let(:transaction_user) { transaction_for(payment_user, user) }

  let(:braintree_api_regex) { %r{POST /merchants/#{ENV['BRAINTREE_MERCHANT_ID']}/transactions (201|422)} }

  before(:each) { generic_seo_and_ao }

  describe 'receipt' do
    # For each describe block, the transaction will be submitted twice.
    # The first time, it should succeed (201).
    # The second time, it should be rejected as a duplicate (422).
    describe 'registration' do
      let(:mail) { ReceiptMailer.receipt(transaction_reg, payment_reg) }

      it 'renders the headers' do
        expect { transaction_reg }.to output(braintree_api_regex).to_stdout_from_any_process
        expect(transaction_reg.status).to be_in(%w[submitted_for_settlement gateway_rejected])

        expect(mail.subject).to eql('Your receipt from Birmingham Power Squadron')
        expect(mail.to).to eql([user.email])
        expect(mail.from).to eql(['receipts@bpsd9.org'])
      end

      it 'renders the body' do
        expect { transaction_reg }.to output(braintree_api_regex).to_stdout_from_any_process
        expect(transaction_user.status).to be_in(%w[submitted_for_settlement gateway_rejected])

        expect(mail.body.encoded).to include('Transaction Receipt')
        expect(mail.body.encoded).to include('Transaction information')
        expect(mail.body.encoded).to match(/(ending in \*\*)|(Paid via PayPal)/)
      end
    end

    describe 'member application' do
      let(:mail) { ReceiptMailer.receipt(transaction_app, payment_app) }

      it 'renders the headers' do
        expect { transaction_app }.to output(braintree_api_regex).to_stdout_from_any_process
        expect(transaction_app.status).to be_in(%w[submitted_for_settlement gateway_rejected])

        expect(mail.subject).to eql('Your receipt from Birmingham Power Squadron')
        expect(mail.to).to eql([user.email])
        expect(mail.from).to eql(['receipts@bpsd9.org'])
      end

      it 'renders the body' do
        expect { transaction_app }.to output(braintree_api_regex).to_stdout_from_any_process
        expect(transaction_user.status).to be_in(%w[submitted_for_settlement gateway_rejected])

        expect(mail.body.encoded).to include('Transaction Receipt')
        expect(mail.body.encoded).to include('Transaction information')
        expect(mail.body.encoded).to match(/(ending in \*\*)|(Paid via PayPal)/)
      end
    end

    describe 'dues' do
      let(:mail) { ReceiptMailer.receipt(transaction_user, payment_user) }

      it 'renders the headers' do
        expect { transaction_user }.to output(braintree_api_regex).to_stdout_from_any_process
        expect(transaction_user.status).to be_in(%w[submitted_for_settlement gateway_rejected])

        expect(mail.subject).to eql('Your receipt from Birmingham Power Squadron')
        expect(mail.to).to eql([user.email])
        expect(mail.from).to eql(['receipts@bpsd9.org'])
      end

      it 'renders the body' do
        expect { transaction_user }.to output(braintree_api_regex).to_stdout_from_any_process
        expect(transaction_user.status).to be_in(%w[submitted_for_settlement gateway_rejected])

        expect(mail.body.encoded).to include('Transaction Receipt')
        expect(mail.body.encoded).to include('Transaction information')
        expect(mail.body.encoded).to match(/(ending in \*\*)|(Paid via PayPal)/)
      end
    end
  end

  describe 'paid' do
    describe 'registration' do
      let(:mail) { ReceiptMailer.paid(payment_reg) }

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
      let(:mail) { ReceiptMailer.paid(payment_app) }

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
      let(:mail) { ReceiptMailer.paid(payment_user) }

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
