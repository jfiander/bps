# frozen_string_literal: true

class LocationsController < ApplicationController
  include Locations::Refresh
  include Concerns::Application::RedirectWithStatus

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
    redirect_with_status(locations_path, object: 'location', verb: 'create') do
      @location = Location.create(location_params)
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

    redirect_with_status(locations_path, object: 'location', verb: 'update') do
      @location.update(location_params)
    end
  end

  def remove
    redirect_with_status(locations_path, object: 'location', verb: 'remove') do
      Location.find_by(id: update_params[:id])&.destroy
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
