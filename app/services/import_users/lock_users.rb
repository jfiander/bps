# frozen_string_literal: true

module ImportUsers
  # User auto-locker for user importing
  class LockUsers
    def initialize(certificates)
      @removed_users = User.where.not(certificate: certificates).to_a
    end

    def call
      # Do not auto-lock any current Bridge Officers.
      @removed_users.reject! { |u| u.in? BridgeOffice.all.map(&:user) }

      # Do not report previously-locked users.
      @removed_users.reject!(&:locked?)

      @removed_users.map(&:lock)
      @removed_users
    end
  end
end
