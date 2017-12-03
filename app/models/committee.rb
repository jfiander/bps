class Committee < ApplicationRecord
  belongs_to :chair, class_name: "User", optional: true

  validates :name, uniqueness: { scope: :department }
  validates :department, inclusion: { in: %w[commander executive educational
    administrative secretary treasurer asst_educational asst_secretary],
    message: "%{value} is not a valid department" }

  def search_name
    name.downcase
  end

  def display_name
    return name unless name.match("//")

    lines = name.split("//")
    committee = lines.shift << "<small>"
    combined = [committee, lines].join("<br>&nbsp;&nbsp;")  << "</small>"
    combined.html_safe
  end
end
