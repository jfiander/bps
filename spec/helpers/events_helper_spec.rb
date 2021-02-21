# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventsHelper, type: :helper do
  describe 'override_icon' do
    before do
      @user = FactoryBot.create(:user)
      @event = FactoryBot.create(:event)
      generic_seo_and_ao
      @reg = FactoryBot.create(:registration, user: @user, event: @event)
    end

    it 'generates the correct normal icon' do
      expect(reg_override_icon(@reg)).to eql(
        "<a href=\"/override_cost/#{@reg.payment.token}\"><i class='fad green fa-file-invoice-dollar fa-1x' " \
        "style='' data-fa-transform='' title='Set override cost'></i></a>"
      )
    end

    it 'generates the correct set icon' do
      @reg.update(override_cost: 1)

      expect(reg_override_icon(@reg)).to eql(
        "<a href=\"/override_cost/#{@reg.payment.token}\"><i class='fas green fa-file-invoice-dollar fa-1x' " \
        "style='' data-fa-transform='' title='Update override cost'></i></a>"
      )
    end

    it 'generates the correct normal paid icon' do
      @reg.payment.paid!('1234567890')

      expect(reg_override_icon(@reg)).to eql(
        "<i class='fad gray fa-file-invoice-dollar fa-1x' style='' data-fa-transform='' " \
        "title='Registration has already been paid'></i>"
      )
    end

    it 'generates the correct set paid icon' do
      @reg.update(override_cost: 1)
      @reg.payment.paid!('1234567890')

      expect(reg_override_icon(@reg)).to eql(
        "<i class='fas gray fa-file-invoice-dollar fa-1x' style='' data-fa-transform='' " \
        "title='Registration has already been paid'></i>"
      )
    end
  end
end
