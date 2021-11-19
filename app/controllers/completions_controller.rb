# frozen_string_literal: true

class CompletionsController < ApplicationController
  secure!(:education)

  before_action(only: :ytd) { @ytd = true }
  before_action(only: :list) { @ytd = false }
  before_action :completions
  before_action :seminar_list
  before_action :course_list
  before_action :exam_list
  before_action :boc_skills_list

  def list; end

  def ytd
    render :list
  end

private

  def completions
    @completions = CourseCompletion.with_users.send(@ytd ? :ytd : :all).by_user
  end

  def seminar_list
    @seminar_list = BPS::CodeList.new.seminars.map do |h|
      h = h.except('green', 'yellow')

      case h['code']
      when String
        { h['code'] => h['name'] }
      when Hash
        multi_seminar_hash(h['code'], h['name'])
      end
    end.compact.reduce({}, :merge)
  end

  def multi_seminar_hash(code, name)
    if code.key?('any')
      code['any'].map { |e| { e => name } }.reduce({}, :merge)
    elsif code.key?('all')
      code['all'].map { |e| { e => name } }.reduce({}, :merge)
    end
  end

  def course_list
    @course_list = BPS::CodeList.new.courses.map do |h|
      { h['code'] => h['name'] }
    end.compact.reduce({}, :merge)
  end

  def exam_list
    @exam_list = BPS::CodeList.new.courses.map do |h|
      { h['exam_prefix'] => "#{h['name']} Exam" }
    end.compact.reduce({}, :merge)
  end

  def boc_skills_list
    @boc_skills_list = BPS::CodeList.new.boc_skills.map do |h|
      { h['code'] => h['name'] }
    end.compact.reduce({}, :merge)
  end
end
