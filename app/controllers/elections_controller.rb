# frozen_string_literal: true

class ElectionsController < ApplicationController
  secure!
  secure!(:admin, only: %i[index create])

  title!('Vote')

  # List all elections and results
  def index
    @elections = Voting::Election.includes(ballots: :votes).all
  end

  # Create a new election
  def new
    @election = Voting::Election.new(open_at: Time.now, closed_at: Time.now + 1.hour)
  end

  def create
    # Style is currently disabled in the view
    @election = Voting::Election.create!({ style: 'single' }.merge(election_params))

    redirect_to elections_path
  end

  # Vote in an election
  def vote
    @election = Voting::Election.find(clean_params[:id])

    @existing_ballot = @election.ballots.find { |b| b.user == current_user }
    return unless @existing_ballot.present?

    flash.now[:notice] = 'You have already voted.'
  end

  def submit_vote
    @election = Voting::Election.find(vote_params[:election_id])

    Voting::Ballot.transaction do
      @ballot = @election.ballots.create!(user: current_user)
      @vote = @ballot.votes.create!(selection: vote_params[:selection])
    end
  rescue ActiveRecord::RecordInvalid => e
    handle_record_invalid(e)
  rescue StandardError => e
    handle_unknown_error(e)
  end

private

  def election_params
    params.require(:election).permit(:description, :style, :restriction, :open_at, :closed_at)
  end

  def vote_params
    params.permit(:election_id, :selection)
  end

  def clean_params
    params.permit(:id)
  end

  def handle_record_invalid(e)
    raise e unless e.message == 'Validation failed: User can only have one vote per election'

    @existing_ballot = @election.ballots.find { |b| b.user == current_user }
    flash.now[:notice] = 'You have already voted.'
    render :vote
  end

  def handle_unknown_error(e)
    Bugsnag.notify(e)
    flash.now[:alert] = 'There was a problem with your vote.'
    flash.now[:error] = 'YOUR VOTE HAS NOT BEEN RECORDED.'
    render :vote
  end
end
