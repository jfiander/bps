# frozen_string_literal: true

class OTWTrainingsController < ApplicationController
  include OTWTrainings::Public
  include OTWTrainings::User

  secure!(except: %i[public public_request])
  secure!(:otw, except: %i[public public_request user user_request user_progress])

  title!('On-the-Water Training')

  before_action :load_all_trainings, only: %i[list user]
  before_action :boc_levels, only: %i[new create edit update]
  before_action :load_otw_training, only: %i[edit update destroy]
  before_action :add_formatting, only: %i[new create]
  before_action :edit_formatting, only: %i[edit update]
  before_action :levels, only: %i[user_progress]
  before_action :icons, only: %i[user_progress]

  def list; end

  def list_requests
    @otw_requests = OTWTrainingUser.all
  end

  def available
    @users = User.alphabetized.unlocked.where.not(jumpstart: nil)
  end

  def new
    @otw_training = OTWTraining.new
  end

  def create
    @otw_training = OTWTraining.new(otw_training_params)

    if @otw_training.save
      flash[:success] = 'Successfully created new OTW Training.'
      redirect_to otw_list_path
    else
      flash.now[:alert] = 'There was a problem creating that OTW Training.'
      flash.now[:error] = @otw_training.errors.full_messages
      render :new
    end
  end

  def edit
    render :new
  end

  def update
    if @otw_training.update(otw_training_params)
      flash[:success] = 'Successfully updated OTW Training.'
      redirect_to otw_list_path
    else
      flash.now[:alert] = 'There was a problem updating that OTW Training.'
      flash.now[:error] = @otw_training.errors.full_messages
      render :new
    end
  end

  def destroy
    if @otw_training.destroy
      flash[:success] = 'Successfully removed OTW Training.'
    else
      flash[:alert] = 'There was a problem removing that OTW Training.'
      flash[:error] = @otw_training.errors.full_messages
    end
    redirect_to otw_list_path
  end

private

  def load_all_trainings
    @otw_trainings = OTWTraining.all.ordered
  end

  def otw_training_params
    params.require(:otw_training).permit(:name, :description, :course_key, :boc_level)
  end

  def load_otw_training
    @otw_training = OTWTraining.find_by(id: otw_user_params[:id])
  end

  def add_formatting
    @otw_title = 'Add OTW Training'
    @otw_route = create_otw_path
  end

  def edit_formatting
    @otw_title = 'Edit OTW Training'
    @otw_route = update_otw_path
  end

  def boc_levels
    @boc_levels = [
      'Inland Navigator',
      'Coastal Navigator',
      'Advanced Coastal Navigator',
      'Offshore Navigator'
    ]
  end

  def user_request_succeeded(otw_request)
    flash[:success] = 'Successfully requested training.'
    OTWMailer.requested(otw_request).deliver
    @check = FA::Icon.p('check', css: 'green', size: 2)
  end

  def user_request_failed(otw_request)
    flash[:alert] = 'Unable to request training.'
    flash[:alert] = otw_request.errors.full_messages
    render status: :unprocessable_entity
  end
end
