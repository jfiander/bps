# frozen_string_literal: true

class LocationsController < ApplicationController
  include Locations::Refresh

  secure!(:event, :course, :seminar)

  title!('Locations')

  ajax!(only: :refresh)

  def list
    @locations = Location.all.order(:id).map(&:display)
  end

  def new
    @location = Location.new
    @edit_action = 'Add'
    @submit_path = create_location_path
  end

  def create
    if (@location = Location.create(location_params))
      redirect_to locations_path, success: 'Successfully created location.'
    else
      flash[:alert] = 'Unable to create location.'
      flash[:errors] = @location.errors.full_messages
      redirect_to locations_path
    end
  end

  def edit
    @location = Location.find_by(id: update_params[:id])
    @edit_action = 'Modify'
    @submit_path = update_location_path
    render :new
  end

  def update
    @location = Location.find_by(id: update_params[:id])

    if @location.update(location_params)
      redirect_to locations_path, success: 'Successfully updated location.'
    else
      flash[:alert] = 'Unable to update location.'
      flash[:errors] = @location.errors.full_messages
      redirect_to locations_path
    end
  end

  def remove
    if Location.find_by(id: update_params[:id])&.destroy
      redirect_to locations_path, success: 'Successfully removed location.'
    else
      flash[:alert] = 'Unable to remove location.'
      flash[:errors] = @location.errors.full_messages
      redirect_to locations_path
    end
  end

  private

  def location_params
    params.require(:location).permit(:address, :map_link, :details, :picture)
  end

  def update_params
    params.permit(:id)
  end
end
