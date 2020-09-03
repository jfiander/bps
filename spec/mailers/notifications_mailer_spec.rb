# frozen_string_literal: true

require 'rails_helper'

def user_identifier(user)
  "#{user.full_name} \\(#{user.certificate}, ##{user.id}\\)"
end

RSpec.describe NotificationsMailer, type: :mailer do
  describe 'bridge office updated' do
    before do
      generic_seo_and_ao
      @previous = FactoryBot.create(:user)
      @by = FactoryBot.create(:user)
      @mail = described_class.bridge(generic_seo_and_ao[:ao], by: @by, previous: @previous)
    end

    it 'renders the headers' do
      expect(@mail).to contain_mail_headers(
        subject: 'Bridge Office Updated', to: ['dev@bpsd9.org'], from: ['support@bpsd9.org']
      )
    end

    it 'renders the body' do
      expect(@mail.body.encoded).to contain_and_match(
        'The following bridge office has been updated.',
        'Office: Administrative Officer',
        /Previous holder:=0D\n#{user_identifier(@previous)}/,
        /New holder:=0D\n#{user_identifier(generic_seo_and_ao[:ao].user)}/,
        /Updated by:=0D\n#{user_identifier(@by)}/
      )
    end
  end

  describe 'new float plan' do
    before do
      @float_plan = FactoryBot.create(:float_plan, :one_onboard)
      @mail = described_class.float_plan(@float_plan)
    end

    context 'with no monitors' do
      it 'renders the headers' do
        expect(@mail).to contain_mail_headers(
          subject: 'Float Plan Submitted', to: ['dev@bpsd9.org'], from: ['support@bpsd9.org']
        )
      end

      it 'renders the body' do
        expect(@mail.body.encoded).to contain_and_match(
          'The following float plan has been submitted.',
          'follow up on this plan',
          'Contact',
          'Travel Times'
        )
      end
    end

    context 'with monitors' do
      it 'sends mail to the monitors' do
        monitor = FactoryBot.create(:user)
        FactoryBot.create(:committee, user: monitor, name: 'Float Plan Monitor')
        expect(@mail.to).to eql([monitor.email])
      end
    end
  end
end
