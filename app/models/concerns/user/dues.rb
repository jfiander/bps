# frozen_string_literal: true

module User::Dues
  def dues
    if parent.present?
      { user_id: parent_id }
    elsif children.blank?
      89
    else
      133 + children.count
    end
  end

  def dues_due?
    return false if parent_id.present?
    return true unless dues_last_paid_at.present?

    dues_last_paid_at < 11.months.ago
  end

  def dues_paid!
    update(dues_last_paid_at: Time.now)
  end
end