# frozen_string_literal: true

class EventPromoCode < ApplicationRecord
  belongs_to :event
  belongs_to :promo_code
end
