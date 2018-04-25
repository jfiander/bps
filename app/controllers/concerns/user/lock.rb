module User::Lock
  def lock
    user = User.find(params[:id])

    if user.permitted?(:admin)
      redirect_to(
        users_path,
        alert: 'Cannot lock an admin user.'
      )
      return
    end

    user.lock
    redirect_to users_path, success: 'Successfully locked user.'
  end

  def unlock
    User.find(clean_params[:id]).unlock

    redirect_to users_path, success: 'Successfully unlocked user.'
  end
end
