# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventsHelper, type: :helper do
  let(:user) { FactoryBot.create(:user) }
  let(:event) { FactoryBot.create(:event) }

  describe 'override_icon' do
    let(:reg) { FactoryBot.create(:registration, user: user, event: event) }

    before { generic_seo_and_ao }

    it 'generates the correct normal icon' do
      expect(reg_override_icon(reg)).to eql(
        "<a href=\"/override_cost/#{reg.payment.token}\"><i class='fad green fa-file-invoice-dollar fa-1x' " \
        "style='' data-fa-transform='' title='Set override cost'></i></a>"
      )
    end

    it 'generates the correct set icon' do
      reg.update(override_cost: 1)

      expect(reg_override_icon(reg)).to eql(
        "<a href=\"/override_cost/#{reg.payment.token}\"><i class='fas green fa-file-invoice-dollar fa-1x' " \
        "style='' data-fa-transform='' title='Update override cost'></i></a>"
      )
    end

    it 'generates the correct normal paid icon' do
      reg.payment.paid!('1234567890')

      expect(reg_override_icon(reg)).to eql(
        "<i class='fad gray fa-file-invoice-dollar fa-1x' style='' data-fa-transform='' " \
        "title='Registration has already been paid'></i>"
      )
    end

    it 'generates the correct set paid icon' do
      reg.update(override_cost: 1)
      reg.payment.paid!('1234567890')

      expect(reg_override_icon(reg)).to eql(
        "<i class='fas gray fa-file-invoice-dollar fa-1x' style='' data-fa-transform='' " \
        "title='Registration has already been paid'></i>"
      )
    end
  end

  describe 'event_flags' do
    let(:committee_1) { FactoryBot.create(:committee) }
    let(:committee_2) { FactoryBot.create(:committee, name: 'Vessel Safety Check') }

    before { @current_user_permitted_event_type = true }

    it 'does not raise any exceptions' do
      expect { event_flags(event) }.not_to raise_error
    end

    it 'generates the correct catalog flag' do
      event.show_in_catalog = true

      expect(event_catalog_flag(event)).to eq(
        '<div class="birmingham-blue" title="This event is shown in the catalog.">' \
        "<i class='fad fa-fw fa-stars fa-1x' style='' data-fa-transform='' title=''></i>" \
        '<small>Catalog</small></div>'
      )
    end

    it 'generates the correct activity flag' do
      event.activity_feed = true

      expect(event_activity_flag(event)).to eq(
        '<div class="birmingham-blue" title="This event is available for display in the activity feed.">' \
        "<i class='fad fa-fw fa-stream fa-1x' style='' data-fa-transform='' title=''></i>" \
        '<small>Activity Feed</small></div>'
      )
    end

    it 'generates the correct invisible flag' do
      event.visible = false

      expect(event_not_visible_flag(event)).to eq(
        '<div class="red" title="This event is not visible to members or the public. Only editors can see it.">' \
        "<i class='fad fa-fw fa-eye-slash fa-1x' style='' data-fa-transform='' title=''></i>" \
        '<small>Not Visible</small></div>'
      )
    end

    it 'generates the correct committees flag with one committee' do
      event.event_type.assign(committee_1)

      expect(event_committees_flag(event)).to eq(
        '<div class="green" title="Will notify the listed committee in addition to the relevant bridge officers.">' \
        "<i class='fad fa-fw fa-envelope fa-1x' style='' data-fa-transform='' title=''></i>" \
        "<small>#{committee_1.name}</small></div>"
      )
    end

    it 'generates the correct committees flag with multiple committees' do
      event.event_type.assign(committee_1.name) # Directly pass in string name
      event.event_type.assign(committee_2) # Pass in actual Committee object

      expect(event_committees_flag(event)).to eq(
        '<div class="green" title="Will notify the listed committee in addition to the relevant bridge officers.">' \
        "<i class='fad fa-fw fa-envelope fa-1x' style='' data-fa-transform='' title=''></i>" \
        "<small>#{committee_1.name}</small></div>" \
        '<div class="green" title="Will notify the listed committee in addition to the relevant bridge officers.">' \
        "<i class='fad fa-fw fa-envelope fa-1x' style='' data-fa-transform='' title=''></i>" \
        "<small>#{committee_2.name}</small></div>"
      )
    end

    it 'generates the correct committees flag with duplicate committees' do
      committee_1.name = 'something'
      committee_2.name = 'something'
      event.event_type.assign(committee_1)
      event.event_type.assign(committee_2)

      expect(event_committees_flag(event)).to eq(
        '<div class="green" title="Will notify the listed committee in addition to the relevant bridge officers.">' \
        "<i class='fad fa-fw fa-envelope fa-1x' style='' data-fa-transform='' title=''></i>" \
        "<small>#{committee_1.name}</small></div>"
      )
    end
  end
end
