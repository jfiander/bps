# frozen_string_literal: true

module Admin
  class PromoCodesController < ApplicationController
    secure!(:admin, strict: true)

    before_action :find_promo_code, only: %i[activate expire]

    def list
      promo_codes = PromoCode.includes(:events, :payments).all

      @promo_codes = {
        pending: promo_codes.pending,
        current: promo_codes.current,
        expired: promo_codes.expired
      }
    end

    def new
      @promo_code = PromoCode.new
      @discount_types = [
        ['Percent off', 'percent'], ['Dollar reduction', 'usd'],
        ['Member cost', 'member'], ['USPS cost', 'usps']
      ]
      @events = Event.includes(:event_type).displayable.reject(&:expired?)
                     .group_by { |e| e.event_type.event_category.titleize }
                     .map do |category, events|
                       { category => events.map { |e| [e.date_title, e.id] } }
                     end.reduce({}, :merge)
    end

    def create
      if PromoCode.find_by(code: promo_params[:code])
        flash[:alert] = 'That code has already been used.'
        redirect_to admin_promo_codes_path
      end

      @promo_code = PromoCode.create(promo_params)

      attach_events

      flash[:success] = "Created promo code #{promo_params[:code]}."
      redirect_to admin_promo_codes_path
    end

    def activate
      @promo_code&.activate!
      redirect_to admin_promo_codes_path
    end

    def expire
      @promo_code&.expire!
      redirect_to admin_promo_codes_path
    end

  private

    def find_promo_code
      @promo_code = PromoCode.find_by(id: clean_params[:id])
    end

    def promo_params
      params.require(:promo_code).permit(
        :code, :valid_at, :expires_at, :discount_type, :discount_amount
      )
    end

    def event_params
      params.require(:promo_code).permit(event_ids: [])
    end

    def clean_params
      params.permit(:id)
    end

    def attach_events
      event_params[:event_ids].map { |i| Event.find_by(id: i.to_i) }.compact.each do |event|
        event&.attach_promo_code(@promo_code.code)
      end
    end
  end
end
