# frozen_string_literal: true

module RosterPDF::Detailed::PastCommanders
  def past_commanders
    load_pc_flag

    formatted_page do
      pc_title
      pc_table
      pc_comments
    end
  end

  private

  def pc_title
    insert_image 'tmp/run/PC.png', at: [0, 540], width: 80
    move_down(20)
    text(
      'Past Commanders',
      size: RosterPDF::Detailed::SECTION_TITLE_SIZE, style: :bold, align: :center
    )
    insert_image 'tmp/run/PC.png', at: [245, 540], width: 80
  end

  def pc_table
    pcs = Roster::PastCommander.all
    return if pcs.blank?
    size = pcs.count > 60 ? 7 : 8
    left, right = pcs.each_slice((pcs.size / 2.0).round).to_a

    pc_table_column(left, size, 20)
    pc_table_column(right, size, 175)
  end

  def pc_table_column(collection, size, x_pos)
    bounding_box([x_pos, 470], width: 150, height: 470) do
      collection&.map { |c| format_pc(c) }&.each do |l|
        text l, size: size, align: :left, inline_format: true
      end
    end
  end

  def pc_comments
    bounding_box([0, 30], width: 325, height: 30) do
      formatted_text(
        [
          { text: "‡ Deceased\n" },
          { text: '* Election date changed from February to December' }
        ],
        size: RosterPDF::Detailed::BODY_SM_SIZE, align: :left, inline_format: true
      )
    end
  end

  def format_pc(pc)
    tags = []
    tags << '‡' if pc.deceased
    tags << '*' if pc.comment.present?
    "<b>#{pc.year&.strftime('%Y')}</b> #{pc.display_name} #{tags.join}"
  end

  def load_pc_flag
    flag = BpsS3.new(:static).download('flags/PNG/PC.500.png')
    File.open('tmp/run/PC.png', 'w+') { |f| f.write(flag) }
  end
end
