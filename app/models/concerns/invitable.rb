module Invitable
  def invitable?
    invitation_accepted_at.blank? &&
      current_sign_in_at.blank? &&
      !locked? &&
      sign_in_count.zero? &&
      !has_placeholder_email?
  end

  def invited?
    invitation_sent_at.present? &&
      invitation_accepted_at.blank?
  end

  def has_placeholder_email?
    email.match(/nobody-.*@bpsd9\.org\z/) ||
      email.match(/duplicate-.*@bpsd9\.org\z/)
  end
end
