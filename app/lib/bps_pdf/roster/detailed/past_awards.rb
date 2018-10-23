# frozen_string_literal: true

module BpsPdf::Roster::Detailed::PastAwards
  def past_awards
    past_award_formatted_page('Bill Booth Moose Milk')
    past_award_formatted_page('Education')
    past_award_formatted_page('Outstanding Service')
    past_award_formatted_page('Master Mariner')

    formatted_page do
      past_award_title('High Flyer')
      past_award_table('High Flyer')

      past_award_title('Jim McMicking Outstanding Instructor', y_pos: 270)
      past_award_table('Jim McMicking Outstanding Instructor', y_pos: 270)
    end
  end

private

  def past_award_formatted_page(name)
    formatted_page do
      past_award_title(name)

      past_award_table(name)
    end
  end

  def past_award_title(name, y_pos: 540)
    bounding_box([0, y_pos], width: 325, height: 40) do
      text(
        'Past Year Award Recipients',
        size: BpsPdf::Roster::Detailed::SECTION_TITLE_SIZE, style: :bold, align: :center
      )
      move_down(10)
      text(
        "#{name} Award", size: BpsPdf::Roster::Detailed::HEADING_SIZE, style: :bold, align: :center
      )
    end
  end

  def past_award_table(name, y_pos: 540)
    past_awards = Roster::AwardRecipient.past(name)
    return if past_awards.blank?
    size = past_awards.count > 60 ? 7 : 8
    past_awards = past_awards.map { |pa| [pa.display_year, pa.display_name] }
    left, right = halve(past_awards)

    past_award_column(left, size, 20, y_pos)
    past_award_column(right, size, 175, y_pos)
  end

  def past_award_column(collection, size, x_pos, y_pos)
    bounding_box([x_pos, y_pos - 40], width: 150, height: 500) do
      collection&.map { |a| "<b>#{a[0]}</b> #{a[1]}" }&.each do |pa|
        text pa, size: size, align: :left, inline_format: true
      end
    end
  end
end
