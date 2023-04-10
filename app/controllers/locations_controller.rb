# frozen_string_literal: true

class LocationsController < ApplicationController
  include Locations::Refresh
  include Application::RedirectWithStatus

  secure!(:event, :course, :seminar)

  title!('Locations')

  before_action :update_form_data, only: %i[edit update]

  def list
    @locations = Location.all.map(&:display)
  end

  def new
    @location = Location.new
    @edit_action = 'Add'
    @submit_path = create_location_path
  end

  def edit
    @location = Location.find_by(id: update_params[:id])
    render :new
  end

  def create
    redirect_with_status(locations_path, object: 'location', verb: 'create') do
      @location = Location.create(location_params)
    end
  end

  def update
    @location = Location.find_by(id: update_params[:id])

    redirect_or_render_error(
      locations_path, render_method: :new, object: 'location', verb: 'update'
    ) do
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
    params.require(:location).permit(
      :address, :map_link, :details, :favorite, :virtual, :price_comment, :picture,
      :delete_attachment
    )
  end

  def update_params
    params.permit(:id)
  end

  def update_form_data
    @edit_action = 'Modify'
    @submit_path = update_location_path
  end
end
