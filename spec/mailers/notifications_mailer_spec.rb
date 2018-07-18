# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotificationsMailer, type: :mailer do
  describe 'bridge office updated' do
    before(:each) do
      @ao = FactoryBot.create(:bridge_office, office: 'administrative')
      @previous = FactoryBot.create(:user)
      @by = FactoryBot.create(:user)
      @mail = NotificationsMailer.bridge(@ao, by: @by, previous: @previous)
    end

    it 'renders the headers' do
      expect(@mail.subject).to eql('Bridge Office Updated')
      expect(@mail.to).to eql(['dev@bpsd9.org'])
      expect(@mail.from).to eql(['support@bpsd9.org'])
    end

    it 'renders the body' do
      expect(@mail.body.encoded).to include(
        'The following bridge office has been updated.'
      )
      expect(@mail.body.encoded).to include(
        'Office: Administrative Officer'
      )
      expect(@mail.body.encoded).to include(
        <<~TEXT
          Previous holder:
          #{@previous.full_name} (#{@previous.certificate}, ##{@previous.id})

          New holder:
          #{@ao.user.full_name} (#{@ao.user.certificate}, ##{@ao.user.id})

          Updated by:
          #{@by.full_name} (#{@by.certificate}, ##{@by.id})
        TEXT
      )
    end
  end

  describe 'new float plan' do
    before(:each) do
      @float_plan = FactoryBot.create(:float_plan, :one_onboard)
      @mail = NotificationsMailer.float_plan(@float_plan)
    end

    context 'no monitors' do
      it 'renders the headers' do
        expect(@mail.subject).to eql('Float Plan Submitted')
        expect(@mail.to).to eql(['dev@bpsd9.org'])
        expect(@mail.from).to eql(['support@bpsd9.org'])
      end

      it 'renders the body' do
        expect(@mail.body.encoded).to include(
          'The following float plan has been submitted.'
        )
        expect(@mail.body.encoded).to include('follow up on this plan')
        expect(@mail.body.encoded).to include('Contact')
        expect(@mail.body.encoded).to include('Travel Times')
      end
    end

    context 'with monitors' do
      it 'sends mail to the monitors' do
        monitor = FactoryBot.create(:user)
        FactoryBot.create(:committee, user: monitor, name: 'float_plan_monitor')
        expect(@mail.to).to eql([monitor.email])
      end
    end
  end
end
