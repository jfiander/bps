class MembersController < ApplicationController
  before_action :authenticate_user!
  before_action only: [:admin] { require_permission(:admin) }

  def index
    #
  end

  def admin
    @admin_menu = true
  end
end
