# frozen_string_literal: true

class User
  module Lock
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
      BPS::Cognito::Admin.new.disable(user.certificate) if Rails.env.production?

      redirect_to users_path, success: 'Successfully locked user.'
    end

    def unlock
      user = User.find(clean_params[:id])

      user.unlock
      BPS::Cognito::Admin.new.enable(user.certificate) if Rails.env.production?

      redirect_to users_path, success: 'Successfully unlocked user.'
    end
  end
end
