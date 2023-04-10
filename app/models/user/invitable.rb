# frozen_string_literal: true

class User
  module Invitable
    extend ActiveSupport::Concern

    def invitable?
      invitation_accepted_at.blank? &&
        current_sign_in_at.blank? &&
        !locked? &&
        sign_in_count.zero? &&
        !placeholder_email?
    end

    def invited?
      invitation_sent_at.present? &&
        invitation_accepted_at.blank?
    end

    def placeholder_email?
      email.match(/nobody-.*@bpsd9\.org\z/) ||
        email.match(/duplicate-.*@bpsd9\.org\z/)
    end
  end
end
