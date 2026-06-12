# frozen_string_literal: true

module Roster
  class PastCommandersController < ::RosterController
    # This class defines no public methods.
    def _; end

  private

    def model
      Roster::PastCommander
    end

    def clean_params
      params.expect(
        roster_past_commander: %i[id user_id name year deceased]
      )
    end
  end
end
