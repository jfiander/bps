class GalleryController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action(except: %i[index show]) { require_permission(:photos) }

  before_action { page_title('Photos') }

  def index
    @albums = Album.includes(:photos).all

    @album = Album.new
    @photo = Photo.new
  end

  def add_album
    remove_album and return if clean_params[:remove].present?

    @album = Album.new(album_params)
    if @album.save
      redirect_to photos_path, success: 'Successfully added album!'
    else
      errors = @album.errors.full_messages
      flash[:alert] = 'There was a problem creating the album.'
      flash[:error] = errors
      redirect_to photos_path
    end
  end

  def show
    @album = Album.find_by(id: clean_params[:id])
    @photo = Photo.new

    return if @album.present?
    flash[:alert] = 'Album not found.'
    redirect_to photos_path
  end

  def upload_photo
    Photo.transaction do
      photo_params[:photo_file].each do |photo_file|
        photo_attributes = photo_params.to_hash.merge(photo_file: photo_file)
        photo = Photo.new(photo_attributes)
        photo.valid? ? photo.save : @failed = true
        raise ActiveRecord::Rollback if @failed
      end
    end

    upload_flashes
    upload_redirect
  end

  def remove_photo
    photo = Photo.find_by(id: clean_params[:id])
    album_id = photo.album_id

    if photo.destroy
      flash[:success] = 'Successfully removed photo!'
    else
      flash[:alert] = 'There was a problem removing the photo.'
    end

    redirect_to show_album_path(album_id)
  end

  def remove_album
    album_attributes = if params[:album].present?
                         album_params
                       else
                         { id: clean_params[:id] }
                       end

    if Album.find_by(album_attributes)&.destroy
      redirect_to photos_path, success: 'Successfully removed album!'
    else
      redirect_to photos_path, alert: 'There was a problem removing the album.'
    end
  end

  private

  def album_params
    params.require(:album).permit(:name)
  end

  def photo_params
    params.require(:photo).permit(:album_id, photo_file: [])
  end

  def clean_params
    params.permit(:id, :remove, :redirect_to_album)
  end

  def upload_flashes
    if @failed
      flash[:alert] = 'There was a problem creating the photo.'
    else
      flash[:success] = 'Successfully added photo!'
    end
  end

  def upload_redirect
    if clean_params[:redirect_to_album].present?
      redirect_to show_album_path(photo_params[:album_id])
    else
      redirect_to photos_path
    end
  end
end
