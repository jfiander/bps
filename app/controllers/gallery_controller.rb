class GalleryController < ApplicationController
  before_action :authenticate_user!, except: [:index] 
  before_action                        only: [:add_album, :edit_album, :remove_album, :upload_photos, :remove_photo, :remove_album] { require_permission(:photos) }

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
      flash[:notice] = 'Successfully added album!'
    else
      flash[:alert] = 'There was a problem creating the album.'
    end

    redirect_to photos_path
  end

  def edit_album
    @album = Album.find_by(id: clean_params[:id])
    @photo = Photo.new

    if @album.blank?
      flash[:alert] = 'Album not found.'
      redirect_to photos_path
    end
  end

  def upload_photo
    Photo.transaction do
      photo_params[:photo_file].each do |photo_file|
        photo_attributes = photo_params.to_hash.merge(photo_file: photo_file)
        photo = Photo.new(photo_attributes)
        if photo.valid?
          photo.save
        else
          @failed = true
          raise ActiveRecord::Rollback
        end
      end
    end

    if defined?(@failed)
      flash[:alert] = 'There was a problem creating the photo.'
    else
      flash[:notice] = 'Successfully added photo!'
    end

    if clean_params[:redirect_to_album].present?
      redirect_to edit_album_path(photo_params[:album_id])
    else
      redirect_to photos_path
    end
  end

  def remove_photo
    photo = Photo.find_by(id: clean_params[:id])
    album_id = photo.album_id

    if photo.destroy
      flash[:notice] = 'Successfully removed photo!'
    else
      flash[:alert] = 'There was a problem removing the photo.'
    end

    redirect_to edit_album_path(album_id)
  end

  def remove_album
    album_attributes = if params[:album].present?
      album_params
    else
      { id: clean_params[:id] }
    end

    if Album.find_by(album_attributes).destroy
      flash[:notice] = 'Successfully removed album!'
    else
      flash[:alert] = 'There was a problem removing the album.'
    end

    redirect_to photos_path
  end

  private

  def album_params
    params.require(:album).permit(:name)
  end

  def photo_params
    params.require(:photo).permit(:album_id, photo_file: [])
  end

  def clean_params
    params.permit(:id, :remove,:redirect_to_album)
  end
end
