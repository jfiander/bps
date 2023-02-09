# frozen_string_literal: true

module Roster
  class AwardRecipientsController < ::RosterController
    before_action :awards, only: %i[list new create edit update]

  private

    def model
      Roster::AwardRecipient
    end

    def awards
      @awards = [
        'Bill Booth Moose Milk',
        'Education',
        'Outstanding Service',
        'Master Mariner',
        'High Flyer',
        'Jim McMicking Outstanding Instructor'
      ]
    end

    def clean_params
      params.require(:roster_award_recipient).permit(
        :id, :award_name, :user_id, :additional_user_id, :name, :year, :photo
      )
    end
  end
end
