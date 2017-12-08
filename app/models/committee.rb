class Committee < ApplicationRecord
  belongs_to :user, optional: true

  validates :department, inclusion: { in: %w[commander executive educational
    administrative secretary treasurer asst_educational asst_secretary],
    message: "%{value} is not a valid department" }

  scope :for_department, ->(department) { where(department: department.to_s) }

  def self.sorted
    Committee.all.
      order(:name).
      group_by { |c| c.department }.
      map do |dept, coms|
        {
          dept => coms.sort_by { |c| c.name.downcase.gsub(/(assistant) (.*)/, '\2//zzzzz') }
        }
      end.reduce({}, :merge)
  end

  def search_name
    name.downcase.gsub(' ', '_').delete("'")
  end

  def display_name
    return name unless name.match("//")

    lines = name.split("//")
    committee = lines.shift << "<small>"
    combined = [committee, lines].join("<br>&nbsp;&nbsp;")  << "</small>"
    combined.html_safe
  end
end
