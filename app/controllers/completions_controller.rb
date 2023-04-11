# frozen_string_literal: true

class CompletionsController < ApplicationController
  secure!(:education)

  before_action(only: :ytd) { @ytd = true }
  before_action(only: %i[list year]) { @ytd = false }
  before_action :completions, except: :year
  before_action :seminar_list
  before_action :course_list
  before_action :exam_list
  before_action :boc_skills_list

  def list; end

  def ytd
    render :list
  end

  def year
    @year = clean_params[:year]
    completions
    render :list
  end

private

  def clean_params
    params.permit(:year)
  end

  def completions
    @completions =
      if @year.present?
        CourseCompletion.with_users.for_year(@year).by_user
      else
        CourseCompletion.with_users.send(@ytd ? :ytd : :all).by_user
      end
  end

  def seminar_list
    @seminar_list = BPS::CodeList.new.seminars.each_with_object({}) do |s, h|
      s = s.except('green', 'yellow', 'purple')

      case s['code']
      when String
        h[s['code']] = s['name']
      when Hash
        h.merge!(multi_seminar_hash(s['code'], s['name']))
      end
    end
  end

  def multi_seminar_hash(code, name)
    if code.key?('any')
      code['any'].index_with { |_e| name }
    elsif code.key?('all')
      code['all'].index_with { |_e| name }
    end
  end

  def course_list
    @course_list = BPS::CodeList.new.courses.each_with_object({}) do |c, h|
      if c['code'].is_a?(Hash) && c['code'].key?('any')
        c['code']['any'].each { |code| h[code] = c['name'] }
      else
        h[c['code']] = c['name']
      end
    end
  end

  def exam_list
    @exam_list = BPS::CodeList.new.courses.each_with_object({}) do |e, h|
      if e['exam_prefix'].is_a?(Hash) && e['exam_prefix'].key?('any')
        e['exam_prefix']['any'].each { |code| h[code] = "#{e['name']} Exam" }
      else
        h[e['exam_prefix']] = "#{e['name']} Exam"
      end
    end
  end

  def boc_skills_list
    @boc_skills_list = BPS::CodeList.new.boc_skills.each_with_object({}) do |b, h|
      if b['code'].is_a?(Hash) && b['code'].key?('any')
        b['code']['any'].each { |code| h[code] = b['name'] }
      else
        h[b['code']] = b['name']
      end
    end
  end
end
