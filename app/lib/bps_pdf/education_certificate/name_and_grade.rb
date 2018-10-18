# frozen_string_literal: true

module BpsPdf::EducationCertificate::NameAndGrade
  def name_and_grade(user, **_)
    name(user)
    achieved(user)
    grade(user)
  end

  private

  def name(user)
    bounding_box([0, 580], width: 540, height: 30) do
      text user.simple_name, align: :center, size: 24
    end
  end

  def achieved(user)
    return unless user.long_grade.present?
    bounding_box([0, 540], width: 540, height: 30) do
      text 'has achieved the grade of', align: :center, size: 14, style: :italic
    end
  end

  def grade(user)
    bounding_box([0, 515], width: 540, height: 30) do
      text user.long_grade, align: :center, size: 24
    end
  end
end
