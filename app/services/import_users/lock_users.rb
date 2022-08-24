# frozen_string_literal: true

module ImportUsers
  # User auto-locker for user importing
  class LockUsers
    def initialize(certificates)
      @certificates = certificates

      @removed_users = User
                       .where(locked_at: nil)                # Do not report already-locked users.
                       .where.not(certificate: certificates) # Find all users not in the import.
    end

    def call
      mark_not_imported

      # Do not auto-lock any current Bridge Officers.
      @removed_users = @removed_users.to_a.reject { |u| u.id.in?(BridgeOffice.pluck(:user_id)) }

      @removed_users.map(&:lock)
      @removed_users
    end

    def mark_not_imported
      User.where(certificate: @certificates).update_all(in_latest_import: true)
      @removed_users.update_all(in_latest_import: false)
      @removed_users
    end
  end
end
