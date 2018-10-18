# frozen_string_literal: true

module BpsPdf::Roster::Detailed::Bridge
  def bridge
    formatted_page do
      bridge_title
      bridge_table
      contacts
    end
  end

  private

  def bridge_title
    bounding_box([0, 540], width: 325, height: 25) do
      text "Elected Officers for #{Date.today.strftime('%Y')}", size:  BpsPdf::Roster::Detailed::SUBTITLE_SIZE, style: :bold, align: :center
    end
  end

  def bridge_table
    bounding_box([0, 520], width: 325, height: 350) do
      bounding_box([0, 350], width: 175, height: 350) do
        bridge_box(:commander, 350)
        bridge_box(:executive, 350 - 44 * 1)
        bridge_box(:educational, 350 - 44 * 2)
        bridge_box(:administrative, 350 - 44 * 3)
        bridge_box(:secretary, 350 - 44 * 4)
        bridge_box(:treasurer, 350 - 44 * 5)
        bridge_box(:asst_educational, 350 - 44 * 6)
        bridge_box(:asst_secretary, 350 - 44 * 7)
      end
    end
  end

  def bridge_box(office, y_pos)
    bridge_office = BridgeOffice.find_by(office: office)
    bounding_box([0, y_pos], width: 175, height: 40) do
      formatted_text(
        [{ text: "#{bridge_office&.title}\n", styles: [:bold] }] +
        format_name((bridge_office&.user&.full_name(html: false) || 'TBD')),
        size:  BpsPdf::Roster::Detailed::SECTION_TITLE_SIZE, align: :left, valign: :center
      )
    end
    return unless bridge_office.present?
    bounding_box([175, y_pos], width: 150, height: 40) do
      formatted_text(
        [{ text: bridge_office.email }],
        size:  BpsPdf::Roster::Detailed::SECTION_TITLE_SIZE, align: :center, valign: :center
      )
    end
  end

  def contacts
    bounding_box([0, 170], width: 325, height: 170) do
      text 'Other Contacts', size:  BpsPdf::Roster::Detailed::SECTION_TITLE_SIZE, style: :bold, align: :center
      move_down(10)
      contact_box('Webmaster', 'Webmaster', 'webmaster@bpsd9.org', 160)
      contact_box('Bilge Chatter Editor', 'Newsletter Editor', 'newsletter@bpsd9.org', 160 - 40 * 1)
      contact_box('Vessel Safety Check', 'Vessel Safety Check', 'vsc@bpsd9.org', 160 - 40 * 2)
      contact_box('Membership', 'Membership', 'membership@bpsd9.org', 160 - 40 * 3)
    end
  end

  def contact_box(name, committee, email, y_pos)
    chair_name = Committee.find_by(name: committee)&.user&.full_name(html: false) || 'TBD'
    return unless chair_name.present?
    bounding_box([0, y_pos], width: 175, height: 40) do
      formatted_text(
        [{ text: "#{name}\n", styles: [:bold] }, { text: chair_name }],
        size:  BpsPdf::Roster::Detailed::HEADING_SIZE, align: :left, valign: :center
      )
    end
    bounding_box([175, y_pos], width: 150, height: 40) do
      formatted_text(
        [{ text: email }],
        size:  BpsPdf::Roster::Detailed::HEADING_SIZE, align: :center, valign: :center
      )
    end
  end
end
