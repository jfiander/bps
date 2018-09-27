# frozen_string_literal: true

module Members::Store
  def request_item
    @item_id = clean_params[:id]
    request = current_user.request_from_store(@item_id)
    if request.valid?
      flash[:success] = "Item requested! We'll be in contact with you " \
                        'shortly regarding quantity, payment, and delivery.'
    elsif request.errors.added?(:store_item, :taken)
      flash.now[:alert] = 'You have already requested this item. We will ' \
                          'contact you regarding quantity, payment, and ' \
                          'delivery.'
      render status: :unprocessable_entity
    else
      flash.now[:alert] = 'There was a problem requesting this item.'
      render status: :internal_server_error
    end
  end

  def fulfill_item
    @request_id = clean_params[:id]
    if ItemRequest.find_by(id: @request_id).fulfill
      flash[:success] = 'Item successfully fulfilled!'
    else
      flash.now[:alert] = 'There was a problem fulfilling this item.'
      render status: :internal_server_error
    end
  end
end
