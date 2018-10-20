# frozen_string_literal: true

class Roster::PastCommandersController < RosterController
private

  def model
    Roster::PastCommander
  end

  def clean_params
    params.require(:roster_past_commander).permit(
      :id, :user_id, :name, :year, :deceased
    )
  end
end
