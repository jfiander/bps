# frozen_string_literal: true

class CodeList
  attr_reader :seminars, :courses

  def initialize
    @seminars ||= YAML.safe_load(
      File.read("#{Rails.root}/app/lib/seminars.yml")
    )
    @courses ||= YAML.safe_load(
      File.read("#{Rails.root}/app/lib/courses.yml")
    )
  end
end
