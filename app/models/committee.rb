class Committee < ApplicationRecord
  belongs_to :user, optional: true

  validates :department, inclusion: {
    in: %w[
      commander executive educational administrative secretary treasurer
      asst_educational asst_secretary
    ],
    message: '%{value} is not a valid department'
  }

  scope :for_department, ->(department) { where(department: department.to_s) }
  scope :get, (lambda do |department, *names|
    includes(:user).for_department(department).where(name: names.map(&:to_s))
  end)
  scope :sorted, (lambda do
    all
    .order(:name)
    .group_by(&:department)
    .map do |dept, coms|
      {
        dept => coms.sort_by do |c|
          c.name.downcase.gsub(
            /(assistant) (.*)/,
            '\2//zzzzz'
          )
        end
      }
    end.reduce({}, :merge)
  end)

  def search_name
    name.downcase.tr(' ', '_').delete("'\"").gsub('assistant_', '')
  end

  def display_name
    return name unless name.match?('//')

    lines = name.split('//')
    committee = lines.shift << '<small>'
    combined = [committee, lines].join('<br>&nbsp;&nbsp;') << '</small>'
    combined.html_safe
  end
end
