class Committee < ApplicationRecord
  belongs_to :chair, class_name: "User", optional: true

  validates :name, uniqueness: { scope: :department }
  validates :department, inclusion: { in: %w[commander executive educational
    administrative secretary treasurer asst_educational asst_secretary],
    message: "%{value} is not a valid department" }

  def search_name
    name.downcase
  end
end
