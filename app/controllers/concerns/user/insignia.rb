# frozen_string_literal: true

class User
  module Insignia
    def insignia
      grade, grade_title = grade_and_title
      membership, membership_title = membership_and_title

      @insignia = { grade: grade, membership: membership }

      @insignia_title = {
        grade: grade_title, membership: membership_title,
        mm: @user.mm&.positive? ? "#{@user.mm} Merit Marks" : nil
      }
    end

  private

    def grade_and_title
      return if @user.grade.blank?

      if @user.ed_pro.present? && @user.grade != 'SN'
        [
          "#{@user.grade.downcase}_edpro",
          "Grade: #{@user.grade} with Educational Proficiency"
        ]
      else
        [@user.grade.downcase, "Grade: #{@user.grade}"]
      end
    end

    def membership_and_title
      return unless @user.life.present? || @user.senior.present?

      if @user.life.present?
        [:life, 'Life Member']
      elsif @user.senior.present?
        [:senior, 'Senior Member']
      end
    end
  end
end
