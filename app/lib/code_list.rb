# frozen_string_literal: true

class CodeList
  attr_reader :seminars, :courses, :boc_skills

  def initialize
    @seminars = YAML.safe_load(File.read("#{Rails.root}/app/lib/seminars.yml"))
    @boc_skills = YAML.safe_load(File.read("#{Rails.root}/app/lib/boc.yml"))
    @courses = YAML.safe_load(File.read("#{Rails.root}/app/lib/courses.yml"))
  end
end
