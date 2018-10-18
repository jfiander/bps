# frozen_string_literal: true

module BpsPdf::Roster::Detailed::Awards
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
    intro_block('Squadron Awards', config_text[:awards][:top], 50)
  end

  def award_block(name, bottom: false)
    recipient = Roster::AwardRecipient.current(name)&.user&.simple_name || Roster::AwardRecipient.current(name)&.name
    additional = Roster::AwardRecipient.current(name)&.additional_user&.simple_name

    y_pos = bottom ? 240 : 490
    bounding_box([0, y_pos], width: 325, height: 210) do
      text "#{name} Award", size:  BpsPdf::Roster::Detailed::HEADING_SIZE, style: :bold, align: :center
      move_down(10)
      text config_text[:awards][name.to_sym], size:  BpsPdf::Roster::Detailed::BODY_REG_SIZE, align: :justify
      award_recipients(name, recipient, additional) if recipient.present?
    end
  end

  def award_recipients(name, recipient, additional)
    move_down(10)
    winner = additional.present? ? 'winners were' : 'winner was'
    text "This year's #{winner}:", size:  BpsPdf::Roster::Detailed::BODY_REG_SIZE, style: :bold, align: :center
    bounding_box([0, 130], width: 175, height: 140) do
      insert_image "tmp/run/#{name}.png", fit: [180, 140], position: :center, vposition: :center
    end
    bounding_box([175, 130], width: 150, height: 140) do
      award_recipient_names(recipient, additional)
    end
  end

  def award_recipient_names(recipient, additional)
    text = [{ text: recipient }]
    text << { text: "\n#{additional}" } if additional.present?
    formatted_text(text, size:  BpsPdf::Roster::Detailed::BODY_REG_SIZE, align: :center, valign: :center)
  end

  def load_award_images
    Roster::AwardRecipient.current.each do |award|
      next unless BpsS3.new(:files)&.has?(award&.photo&.path)

      photo = BpsS3.new(:files)&.download(award&.photo&.path)
      File.open("tmp/run/#{award.award_name}.png", 'w+') do |f|
        f.write(photo)
      end
    end
  end
end
