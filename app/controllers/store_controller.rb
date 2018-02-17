class StoreController < ApplicationController
  before_action :authenticate_user!
  before_action { require_permission(:store) }

  before_action :get_item, only: [:edit, :update, :destroy]

  before_action { page_title("Ship's Store") }

  def new
    @submit_path = create_store_item_path
    @edit_mode = "Add"
    @store_item = StoreItem.new(price: 0.00, stock: 0)
  end

  def create
    @store_item = StoreItem.create(store_params)
    if @store_item.valid?
      redirect_to store_path, notice: "Successfully added item."
    else
      @submit_path = create_store_item_path
      @edit_mode = "Add"
      flash[:alert] = "Unable to add item."
      render :new
    end
  end

  def edit
    @submit_path = update_store_item_path
    @edit_mode = "Edit"
    render :new
  end

  def update
    @store_item.update(store_params)
    if @store_item.valid?
      redirect_to store_path, notice: "Successfully updates item."
    else
      @submit_path = update_store_item_path
      @edit_mode = "Edit"
      flash[:alert] = "Unable to update item."
      render :new
    end
  end

  def destroy
    flash = if @store_item.destroy
      {notice: "Successfully removed item."}
    else
      {alert: "Unable to remove item."}
    end

    redirect_to store_path, flash
  end

  private
  def store_params
    params.require(:store_item).permit(:id, :name, :description, :price, :options, :stock, :image)
  end

  def update_params
    params.permit(:id)
  end

  def get_item
    @store_item = StoreItem.find_by(id: update_params[:id] || store_params[:id])
  end
end
