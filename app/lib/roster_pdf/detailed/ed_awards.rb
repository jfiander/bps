# frozen_string_literal: true

module RosterPDF::Detailed::EdAwards
  def ed_awards
    formatted_page { education_intro }
    formatted_page { ed_ach }
    formatted_page { ed_pro }
  end

  private

  def education_intro
    span(325) do
      config_text[:education][:introduction].each do |t|
        text t, size: RosterPDF::Detailed::BODY_REG_SIZE, align: :justify, inline_format: true
        text '<br>', size: RosterPDF::Detailed::BODY_REG_SIZE, inline_format: true
      end
    end
  end

  def ed_ach
    bounding_box([0, 540], width: 325, height: 20) do
      text(
        'We are proud of the educational accomplishments of our members!',
        size: RosterPDF::Detailed::BODY_REG_SIZE, style: :bold, align: :center
      )
    end

    bounding_box([0, 520], width: 325, height: 70) do
      text(
        'Educational Achievement Award',
        size: RosterPDF::Detailed::HEADING_SIZE, style: :bold, align: :center
      )
      move_down(10)

      text config_text[:education][:EdAch], size: RosterPDF::Detailed::BODY_REG_SIZE, align: :justify, inline_format: true
    end

    sn_svg = USPSFlags::Grades.new { |g| g.grade = :sn; g.outfile = '' }.svg
    svg sn_svg, width: 1325, at: [0, cursor]

    sns = User.alphabetized.unlocked.where(grade: 'SN').to_a
    return unless sns.size.positive?
    left, right = sns.each_slice((sns.size / 2.0).round).to_a
    size = sns.size > 70 ? 7 : 8

    bounding_box([0, 350], width: 325, height: 350) do
      text config_text[:education]['EdAch proud'.to_sym], size: RosterPDF::Detailed::BODY_REG_SIZE, align: :justify, inline_format: true

      bounding_box([20, 320], width: 150, height: 320) do
        left&.map(&:simple_name)&.each do |l|
          text l, size: size, align: :left, inline_format: true
        end
      end

      bounding_box([175, 320], width: 150, height: 320) do
        right&.map(&:simple_name)&.each do |r|
          text r, size: size, align: :left, inline_format: true
        end
      end
    end
  end

  def ed_pro
    bounding_box([0, 540], width: 325, height: 70) do
      text(
        'Educational Proficiency Award',
        size: RosterPDF::Detailed::HEADING_SIZE, style: :bold, align: :center
      )
      move_down(10)

      text config_text[:education][:EdPro], size: RosterPDF::Detailed::BODY_REG_SIZE, align: :justify, inline_format: true
    end

    edpro_svg = USPSFlags::Grades.new { |g| g.grade = :ap; g.edpro = true; g.outfile = '' }.svg
    svg edpro_svg, width: 1125, at: [90, cursor]

    ed_pros = User.alphabetized.unlocked.where.not(ed_pro: nil).where(ed_ach: nil).to_a
    return unless ed_pros.size.positive?
    left, right = ed_pros.each_slice((ed_pros.size / 2.0).round).to_a
    size = ed_pros.size > 70 ? 7 : 8

    bounding_box([0, 380], width: 325, height: 380) do
      text config_text[:education]['EdPro proud'.to_sym], size: RosterPDF::Detailed::BODY_REG_SIZE, align: :justify, inline_format: true

      bounding_box([20, 350], width: 150, height: 350) do
        left&.map(&:simple_name)&.each do |l|
          text l, size: size, align: :left, inline_format: true
        end
      end

      bounding_box([175, 350], width: 150, height: 350) do
        right&.map(&:simple_name)&.each do |r|
          text r, size: size, align: :left, inline_format: true
        end
      end
    end
  end
end
