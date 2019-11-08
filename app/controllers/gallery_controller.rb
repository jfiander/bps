# frozen_string_literal: true

class GalleryController < ApplicationController
  secure!(except: %i[index show])
  secure!(:photos, except: %i[index show])

  title!('Photos')

  def index
    @albums = Album.includes(:photos).order(created_at: :desc).all
    @album = Album.new
    @photo = Photo.new
  end

  def add_album
    return remove_album if clean_params[:remove].present?

    @album = Album.new(album_params)
    if @album.save
      redirect_to photos_path, success: 'Successfully added album!'
    else
      failed_to_save
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
      photo_params[:photo_file].each { |photo| process_photo_upload(photo) }
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
    if album&.destroy
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

  def album
    @album = Album.find_by(
      params[:album].present? ? album_params : { id: clean_params[:id] }
    )
  end

  def process_photo_upload(photo_file)
    photo_attributes = photo_params.to_hash.merge(photo_file: photo_file)
    photo = Photo.new(photo_attributes)
    photo.valid? ? photo.save! : @failed = true
    raise ActiveRecord::Rollback if @failed
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

  def failed_to_save
    errors = @album.errors.full_messages
    flash[:alert] = 'There was a problem creating the album.'
    flash[:error] = errors
    redirect_to photos_path
  end
end
