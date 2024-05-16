# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReceiptMailer do
  let!(:user) { create(:user) }
  let(:event) { create(:event, cost: 10) }
  let(:reg) { create(:registration, user: user, event: event) }
  let(:app) { create(:family_application) }
  let(:generic) { create(:generic_payment, email: 'nobody@example.com') }

  let(:transaction_struct) do
    Struct.new(
      :id, :created_at, :amount, :customer_details, :promo_code, :payment_instrument_type,
      :credit_card_details, :paypal_details, :apple_pay_details
    )
  end
  let(:customer_struct) { Struct.new(:email) }
  let(:card_struct) { Struct.new(:card_type, :image_url, :last_4) }
  let(:paypal_struct) { Struct.new(:payer_email, :image_url) }

  let(:transaction) do
    transaction_struct.new(
      SecureRandom.hex(8),
      Time.zone.now,
      10,
      customer_struct.new(user.email),
      '',
      'credit_card',
      card_struct.new('AMEX', '', '1234'),
      {},
      {}
    )
  end

  before { generic_seo_and_ao }

  describe 'receipt' do
    describe 'registration' do
      describe 'mail' do
        let(:payment) { create(:payment, parent: reg) }
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
            'AMEX ending in **1234'
          )
        end

        context 'with PayPal' do
          let(:transaction) do
            transaction_struct.new(
              SecureRandom.hex(8),
              Time.zone.now,
              10,
              customer_struct.new(user.email),
              '',
              'paypal_account',
              card_struct.new(nil, nil, nil),
              paypal_struct.new('test@example.com', ''),
              {}
            )
          end

          it 'renders the body' do
            expect(mail.body.encoded).to contain_and_match(
              'Transaction Receipt', 'Transaction information',
              'PayPal', 'test@example.com'
            )
          end
        end

        context 'with Apple Pay' do
          let(:transaction) do
            transaction_struct.new(
              SecureRandom.hex(8),
              Time.zone.now,
              10,
              customer_struct.new(user.email),
              '',
              'apple_pay_card',
              card_struct.new(nil, nil, nil),
              {},
              card_struct.new('Apple Pay - AMEX', '', '1234')
            )
          end

          it 'renders the body' do
            expect(mail.body.encoded).to contain_and_match(
              'Transaction Receipt', 'Transaction information',
              'Apple Pay - AMEX ending in **1234'
            )
          end
        end
      end
    end

    describe 'member application' do
      let(:payment) { create(:payment, parent: app) }

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
            /(ending in \*\*)|(PayPal)/
          )
        end
      end
    end

    describe 'dues' do
      let(:payment) { create(:payment, parent: user) }

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
            'AMEX ending in **1234'
          )
        end
      end
    end
  end

  describe 'paid' do
    describe 'registration' do
      let(:payment) { create(:payment, parent: reg) }
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
      let(:payment) { create(:payment, parent: app) }
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
      let(:payment) { create(:payment, parent: user) }
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
      let(:payment) { create(:payment, parent: generic) }
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
