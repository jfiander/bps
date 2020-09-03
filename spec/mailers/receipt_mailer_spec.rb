# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReceiptMailer, type: :mailer do
  let(:user) { FactoryBot.create(:user) }
  let(:event) { FactoryBot.create(:event, cost: 10) }
  let(:reg) { FactoryBot.create(:registration, user: user, event: event) }
  let(:app) { FactoryBot.create(:family_application) }
  let(:generic) { FactoryBot.create(:generic_payment, email: 'nobody@example.com') }

  # Collisions can occur between multiple simultaneous test suites. Restart any failed suites.
  let(:braintree_api_regex) { %r{POST /merchants/#{ENV['BRAINTREE_MERCHANT_ID']}/transactions 201} }

  def payment(parent)
    FactoryBot.create(:payment, parent: parent)
  end

  def transaction_for(parent, user)
    payment(parent).sale!('fake-valid-nonce', email: user.email, user_id: user.id).transaction
  end

  def ensure_transaction(parent)
    $receipt_email ||= user.email
    $tr ||= transaction_for(parent, user)
  end

  before { generic_seo_and_ao }

  describe 'receipt' do
    describe 'registration' do
      it 'submits the transaction successfully' do
        $receipt_email = user.email
        expect { $tr = transaction_for(reg, user) }.to output(braintree_api_regex).to_stdout_from_any_process
        expect($tr.status).to be_in(%w[submitted_for_settlement gateway_rejected])
      end

      describe 'mail' do
        let(:mail) { described_class.receipt(payment(reg), ensure_transaction(reg)) }

        it 'renders the headers' do
          expect(mail).to contain_mail_headers(
            subject: 'Your receipt from Birmingham Power Squadron',
            to: [$receipt_email],
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
      it 'submits the transaction successfully' do
        $receipt_email = user.email
        expect { $tr = transaction_for(app, user) }.to output(braintree_api_regex).to_stdout_from_any_process
        expect($tr.status).to be_in(%w[submitted_for_settlement gateway_rejected])
      end

      describe 'mail' do
        let(:mail) { described_class.receipt(payment(app), ensure_transaction(app)) }

        it 'renders the headers' do
          expect(mail).to contain_mail_headers(
            subject: 'Your receipt from Birmingham Power Squadron',
            to: [$receipt_email],
            from: ['receipts@bpsd9.org']
          )
          expect(mail.subject).to eql('Your receipt from Birmingham Power Squadron')
          expect(mail.to).to eql([$receipt_email])
          expect(mail.from).to eql(['receipts@bpsd9.org'])
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
      it 'submits the transaction successfully' do
        $receipt_email = user.email
        expect { $tr = transaction_for(user, user) }.to output(braintree_api_regex).to_stdout_from_any_process
        expect($tr.status).to be_in(%w[submitted_for_settlement gateway_rejected])
      end

      describe 'mail' do
        let(:mail) { described_class.receipt(payment(user), ensure_transaction(user)) }

        it 'renders the headers' do
          expect(mail).to contain_mail_headers(
            subject: 'Your receipt from Birmingham Power Squadron',
            to: [$receipt_email],
            from: ['receipts@bpsd9.org']
          )
          expect(mail.subject).to eql('Your receipt from Birmingham Power Squadron')
          expect(mail.to).to eql([$receipt_email])
          expect(mail.from).to eql(['receipts@bpsd9.org'])
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
      let(:mail) { described_class.paid(payment(reg)) }

      it 'renders the headers' do
        expect(mail).to contain_mail_headers(
          subject: 'Registration paid',
          to: ['seo@bpsd9.org', 'aseo@bpsd9.org', 'treasurer@bpsd9.org'],
          from: ['support@bpsd9.org']
        )
        expect(mail.subject).to eql('Registration paid')
        expect(mail.to).to eql(['seo@bpsd9.org', 'aseo@bpsd9.org', 'treasurer@bpsd9.org'])
        expect(mail.from).to eql(['support@bpsd9.org'])
      end

      it 'renders the body' do
        expect(mail.body.encoded).to contain_and_match(
          'This is an automated message that was sent to',
          'Paid Registration', 'Amount paid: $'
        )
      end
    end

    describe 'member application' do
      let(:mail) { described_class.paid(payment(app)) }

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
      let(:mail) { described_class.paid(payment(user)) }

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
      let(:mail) { described_class.paid(payment(generic)) }

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
