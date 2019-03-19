# frozen_string_literal: true

module Concerns::Payment::PromoCodes
  def attach_promo_code(code, **args)
    promo_code = PromoCode.find_by(code: code)
    promo_code ||= PromoCode.create(code: code, **args)
    update(promo_code: promo_code) if promo_code&.usable?
  end

private

  def discount
    base = parent&.payment_amount
    return base unless promo_code&.discount_type&.present?

    discount_cost(promo_code.discount_type, base)
  end

  def discount_cost(key, base)
    {
      'percent' => percent_discount(base), 'usd' => usd_discount(base),
      'member' => member_discount, 'usps' => usps_discount
    }[key]
  end

  def percent_discount(base)
    base * (1.00 - promo_code.discount_amount.to_f / 100)
  end

  def usd_discount(base)
    return nil unless promo_code.discount_amount.present?

    promo_code.discount_amount > base ? 0 : base - promo_code.discount_amount
  end

  def member_discount
    parent.event.member_cost || parent.event.cost
  end

  def usps_discount
    parent.event.usps_cost || parent.event.cost
  end
end
