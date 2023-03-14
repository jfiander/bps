# frozen_string_literal: true

module BPS
  class CodeList
    attr_reader :seminars, :courses, :boc_skills

    def initialize
      @seminars = YAML.safe_load(Rails.root.join('app/lib/seminars.yml').read)
      @boc_skills = YAML.safe_load(Rails.root.join('app/lib/boc.yml').read)
      @courses = YAML.safe_load(Rails.root.join('app/lib/courses.yml').read)
    end
  end
end
