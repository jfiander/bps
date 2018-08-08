class OTWTrainingsController < ApplicationController
  secure!
  secure!(:otw, except: %i[user user_request])

  before_action :load_otw_training, only: %i[edit update destroy]
  before_action :add_formatting, only: %i[new create]
  before_action :edit_formatting, only: %i[edit update]

  def list
    @otw_trainings = OTWTraining.all
  end

  def user
    @otw_trainings = OTWTraining.all
    @otw_requests = current_user&.otw_trainings&.where('otw_training_users.created_at > ?', Date.today - 6.months)
    @otw_credits = @otw_trainings.select { |o| o.course_key.in?(current_user.completions.keys) }
  end

  def user_request
    @otw = OTWTraining.find_by(id: otw_user_params[:id])

    if (otw_request = OTWTrainingUser.find_or_create_by(otw_training: @otw, user: current_user))
      user_request_succeeded(otw_request)
    else
      user_request_failed(otw_request)
    end
  end

  def list_requests
    @otw_requests = OTWTrainingUser.all
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

  def otw_training_params
    params.require(:otw_training).permit(:name, :description, :course_key)
  end

  def otw_user_params
    params.permit(:id)
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
