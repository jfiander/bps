class LocationsController < ApplicationController
  before_action :authenticate_user!
  before_action { require_permission(:event, :course, :seminar, :page) }

  before_action { page_title('Locations') }

  skip_before_action :prerender_for_layout, only: :refresh

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

  def refresh
    @new_locations = ''.html_safe
    @new_locations << '<option value=\"\">Please select a location</option>'.html_safe
    @new_locations << '<option value=\"\"></option>'.html_safe
    @new_locations << '<option value=\"TBD\">TBD</option>'.html_safe

    event = Event.find_by(id: update_params[:id].to_i)

    Location.searchable.each do |id, l|
      @new_locations << '<option value=\"'.html_safe
      @new_locations << id.to_s
      @new_locations << '\"'.html_safe
      @new_locations << ' selected=\"selected\"'.html_safe if id == event.location_id
      @new_locations << '>'.html_safe
      @new_locations << l[:name].strip
      @new_locations << '</option>'.html_safe
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
