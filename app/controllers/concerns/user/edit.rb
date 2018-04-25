module User::Edit
  def assign_photo
    photo = clean_params[:photo]

    if User.find_by(id: clean_params[:id]).assign_photo(local_path: photo.path)
      flash[:success] = 'Successfully assigned profile photo!'
    else
      flash[:alert] = 'Unable to assign profile photo.'
    end

    dest_path = case clean_params[:redirect_to]
    when 'show'
      user_path(clean_params[:id])
    when 'list'
      users_path
    when 'bridge'
      bridge_path
    else
      users_path
    end
    redirect_to dest_path
  end

  def auto_show
    session[:auto_shows] ||= []
    unless session[:auto_shows].include? clean_params[:page_name]
      session[:auto_shows] << clean_params[:page_name]
    end
    head :ok
  end

  def auto_hide
    session[:auto_shows] ||= []
    if session[:auto_shows].include? clean_params[:page_name]
      session[:auto_shows].delete(clean_params[:page_name])
    end
    head :ok
  end
end
