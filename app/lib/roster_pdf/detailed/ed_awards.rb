# frozen_string_literal: true

module RosterPDF::Detailed::EdAwards
  def ed_awards
    formatted_page { education_intro }

    formatted_page do
      ed_awards_intro
      ed_ach
    end

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
    ed_award_builder(
      award: :EdAch, long_award: 'Achievement', y_1: 520, y_2: 350,
      ed_pro: false, ed_ach: true, x_pos: -5
    )
  end

  def ed_pro
    ed_award_builder(
      award: :EdPro, long_award: 'Proficiency', y_1: 540, y_2: 380,
      ed_pro: true, ed_ach: false, x_pos: 80
    )
  end

  def ed_award_builder(options = {})
    ed_award_heading(options[:long_award], options[:y_1], options[:award])
    ed_award_image(options[:award], options[:x_pos])
    left, right, size = ed_award_collections(
      ed_ach: options[:ed_ach], ed_pro: options[:ed_pro]
    )
    ed_award_body(
      y_pos: options[:y_2], key: options[:award],
      left: left, right: right, size: size
    )
  end

  def ed_awards_intro
    bounding_box([0, 540], width: 325, height: 20) do
      text(
        'We are proud of the educational accomplishments of our members!',
        size: RosterPDF::Detailed::BODY_REG_SIZE, style: :bold, align: :center
      )
    end
  end

  def ed_award_heading(award, y_pos, key)
    bounding_box([0, y_pos], width: 325, height: 70) do
      text(
        "Educational #{award} Award",
        size: RosterPDF::Detailed::HEADING_SIZE, style: :bold, align: :center
      )

      move_down(10)

      text(
        config_text[:education][key],
        size: RosterPDF::Detailed::BODY_REG_SIZE, align: :justify, inline_format: true
      )
    end
  end

  def ed_award_image(award, x_pos)
    grade = if award == :EdAch
              :sn
            elsif award == :EdPro
              :ap
            end

    svg ed_award_svg(grade, (award == :EdPro)), width: 1325, at: [x_pos, cursor]
  end

  def ed_award_svg(grade, ed_pro)
    USPSFlags::Grades.new do |g|
      g.grade = grade
      g.edpro = true if ed_pro
      g.outfile = ''
    end.svg
  end

  def ed_award_collections(ed_pro: false, ed_ach: false)
    raise 'Only select one award.' if ed_pro && ed_ach

    users = User.alphabetized.unlocked
    users = users.where.not(ed_pro: nil).where(ed_ach: nil) if ed_pro
    users = users.where(grade: 'SN') if ed_ach
    ed_award_results(users.to_a)
  end

  def ed_award_results(users)
    return unless users.size.positive?
    left, right = halve(users)
    size = users.size > 70 ? RosterPDF::Detailed::BODY_SM_SIZE : RosterPDF::Detailed::BODY_REG_SIZE

    [left, right, size]
  end

  def ed_award_body(options = {})
    bounding_box([0, options[:y_pos]], width: 325, height: options[:y_pos]) do
      text(
        config_text[:education]["#{options[:key]} proud".to_sym],
        size: RosterPDF::Detailed::BODY_REG_SIZE, align: :justify, inline_format: true
      )

      ed_award_column(options[:left], 20, options[:y_pos], options[:size])
      ed_award_column(options[:right], 175, options[:y_pos], options[:size])
    end
  end

  def ed_award_column(collection, x_pos, y_pos, size)
    bounding_box([x_pos, y_pos - 30], width: 150, height: y_pos - 30) do
      collection&.map(&:simple_name)&.each do |l|
        text l, size: size, align: :left, inline_format: true
      end
    end
  end
end
