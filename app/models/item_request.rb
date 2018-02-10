class ItemRequest < ApplicationRecord
  belongs_to :user
  belongs_to :store_item

  scope :outstanding, -> { where(fulfilled: false) }

  # validates :store_item, uniqueness: { scope: :user }, if: :fulfilled?

  acts_as_paranoid

  def fulfill
    # update(fulfilled: true)
    destroy
  end

  # private
  # def fulfilled?
  #   self.fulfilled
  # end
end
