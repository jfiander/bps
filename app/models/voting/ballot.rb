# frozen_string_literal: true

module Voting
  class Ballot < ApplicationRecord
    belongs_to :election
    belongs_to :user
    has_many :votes

    before_save { raise Voting::Election::ClosedElection unless election.open? }

    validates :user, uniqueness: { scope: :election, message: 'can only vote once per election' }

    validate :protect_changes
    validate :restrict_user, if: -> { election.restricted? }

    def protect_changes
      errors.add(:election_id, 'cannot be modified') if election_id_changed? && persisted?

      errors.add(:user_id, 'cannot be modified') if user_id_changed? && persisted?
    end

    def restrict_user
      user_check = Voting::Election::RESTRICTIONS[election.restriction.to_sym]
      return true if user.public_send("#{user_check}?")

      errors.add(:base, 'Not permitted to vote in this election')
    end

    def yes_no?
      raise 'Can only use yes_no? for single votes' unless election.style == 'single'

      votes.first.selection == 'Yes'
    end
  end
end
