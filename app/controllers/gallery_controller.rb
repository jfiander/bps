class GalleryController < ApplicationController
  before_action :authenticate_user!, except: [:index] 
  before_action                        only: [:add_album, :remove_album, :upload_photos, :remove_photo] { require_permission(:photos) }
  def index
    @albums = Album.includes(:photos).all

    @album = Album.new
    @photo = Photo.new
  end

  def add_album
    if remove_params[:remove].present?
      if Album.find_by(album_params).destroy
        flash[:notice] = "Successfully removed album!"
      else
        flash[:alert] = "There was a problem removing the album."
      end
    else
      @album = Album.new(album_params)
      if @album.save
        flash[:notice] = "Successfully added album!"
      else
        flash[:alert] = "There was a problem creating the album."
      end
    end

    redirect_to photos_path
  end

  def upload_photo
    @photo = Photo.new(photo_params)

    if @photo.save
      flash[:notice] = "Successfully added photo!"
    else
      flash[:alert] = "There was a problem creating the photo."
    end

    redirect_to photos_path
  end

  def remove_photo
  end

  private

  def album_params
    params.require(:album).permit(:name)
  end

  def photo_params
    params.require(:photo).permit(:album_id, :photo_file)
  end

  def remove_params
    params.permit(:remove)
  end
end
