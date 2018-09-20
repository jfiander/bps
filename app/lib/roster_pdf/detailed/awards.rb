# frozen_string_literal: true

module RosterPDF::Detailed::Awards
  def awards
    load_award_images

    formatted_page do
      award_intro
      award_block('Bill Booth Moose Milk')
      award_block('Education', bottom: true)
    end

    formatted_page do
      award_intro
      award_block('Outstanding Service')
      award_block('Master Mariner', bottom: true)
    end

    formatted_page do
      award_intro
      award_block('High Flyer')
      award_block('Jim McMicking Outstanding Instructor', bottom: true)
    end
  end

  private

  def award_intro
    bounding_box([0, 540], width: 325, height: 50) do
      text 'Squadron Awards', size: RosterPDF::Detailed::SECTION_TITLE_SIZE, style: :bold, align: :center
      move_down(10)
      text config_text[:awards][:top], size: RosterPDF::Detailed::BODY_REG_SIZE, align: :justify
    end
  end

  def award_block(name, bottom: false)
    recipient = AwardRecipient.current(name)&.user&.simple_name || AwardRecipient.current(name)&.name
    additional = AwardRecipient.current(name)&.additional_user&.simple_name

    y_pos = bottom ? 240 : 490
    bounding_box([0, y_pos], width: 325, height: 210) do
      text "#{name} Award", size: RosterPDF::Detailed::HEADING_SIZE, style: :bold, align: :center
      move_down(10)
      text config_text[:awards][name.to_sym], size: RosterPDF::Detailed::BODY_REG_SIZE, align: :justify
      award_recipients(name, recipient, additional) if recipient.present?
    end
  end

  def award_recipients(name, recipient, additional)
    move_down(10)
    winner = additional.present? ? 'winners were' : 'winner was'
    text "This year's #{winner}:", size: RosterPDF::Detailed::BODY_REG_SIZE, style: :bold, align: :center
    bounding_box([0, 130], width: 175, height: 140) do
      insert_image "tmp/run/#{name}.png", height: 140
    end
    bounding_box([175, 130], width: 150, height: 140) do
      award_recipient_names(recipient, additional)
    end
  end

  def award_recipient_names(recipient, additional)
    text = [{ text: recipient }]
    text << { text: additional } if additional.present?
    formatted_text(text, size: RosterPDF::Detailed::BODY_REG_SIZE, align: :center, valign: :center)
  end

  def load_award_images
    AwardRecipient.current.each do |award|
      next unless BpsS3.new(:files)&.has?(award&.photo&.path)

      photo = BpsS3.new(:files)&.download(award&.photo&.path)
      File.open("tmp/run/#{award.award_name}.png", 'w+') do |f|
        f.write(photo)
      end
    end
  end
end
