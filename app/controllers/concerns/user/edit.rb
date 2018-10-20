# frozen_string_literal: true

module User::Edit
  def assign_photo
    photo = clean_params[:photo]

    if User.find_by(id: clean_params[:id]).assign_photo(local_path: photo.path)
      flash[:success] = 'Successfully assigned profile photo!'
    else
      flash[:alert] = 'Unable to assign profile photo.'
    end

    redirect_to assign_photo_dest_path
  end

  def auto_show
    auto_shows << clean_params[:page_name]
    head :ok
  end

  def auto_hide
    auto_shows.delete(clean_params[:page_name])
    head :ok
  end

private

  def auto_shows
    session[:auto_shows] ||= Set.new
  end

  def assign_photo_dest_path
    case clean_params[:redirect_to]
    when 'show'
      user_path(clean_params[:id])
    when 'list'
      users_path
    when 'bridge'
      bridge_path
    else
      users_path
    end
  end
end
