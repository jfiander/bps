# frozen_string_literal: true

module ElectionsHelper
  def election_restriction_display(election)
    return if election.restriction.blank?

    Voting::Election::RESTRICTIONS[election.restriction].to_s.titleize
  end

  def election_state_color(election)
    return 'green' if election.open?
    return 'red' if election.closed?

    'gold'
  end
end
