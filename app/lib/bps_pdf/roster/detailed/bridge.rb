# frozen_string_literal: true

module BpsPdf
  class Roster
    class Detailed
      module Bridge
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
            text(
              "Elected Officers for #{Date.today.strftime('%Y')}",
              size: BpsPdf::Roster::Detailed::SUBTITLE_SIZE, style: :bold, align: :center
            )
          end
        end

        def bridge_table
          bounding_box([0, 520], width: 325, height: 350) do
            bounding_box([0, 350], width: 175, height: 350) do
              %i[
                commander executive educational administrative secretary treasurer
                asst_educational asst_secretary
              ].each_with_index do |officer, index|
                bridge_box(officer, 350 - 44 * index)
              end
            end
          end
        end

        def bridge_box(office, y_pos)
          bridge_office = BridgeOffice.find_by(office: office)
          bridge_box_office(bridge_office, y_pos)
          return unless bridge_office.present?

          bridge_box_email(bridge_office, y_pos)
        end

        def bridge_box_office(bridge_office, y_pos)
          bounding_box([0, y_pos], width: 175, height: 40) do
            formatted_text(
              [{ text: "#{bridge_office&.title}\n", styles: [:bold] }] +
              format_name((bridge_office&.user&.full_name(html: false) || 'TBD')),
              size: BpsPdf::Roster::Detailed::SECTION_TITLE_SIZE, align: :left, valign: :center
            )
          end
        end

        def bridge_box_email(bridge_office, y_pos)
          bounding_box([175, y_pos], width: 150, height: 40) do
            formatted_text(
              [{ text: bridge_office.email }],
              size: BpsPdf::Roster::Detailed::SECTION_TITLE_SIZE, align: :center, valign: :center
            )
          end
        end

        def contacts
          bounding_box([0, 170], width: 325, height: 170) do
            text(
              'Other Contacts',
              size: BpsPdf::Roster::Detailed::SECTION_TITLE_SIZE, style: :bold, align: :center
            )
            move_down(10)
            other_contacts_list
          end
        end

        def other_contacts_list
          contact_box('Webmaster', 'Webmaster', 'webmaster@bpsd9.org', 160)
          contact_box(
            'Bilge Chatter Editor', 'Newsletter Editor', 'newsletter@bpsd9.org', 160 - 40 * 1
          )
          contact_box('Vessel Safety Check', 'Vessel Safety Check', 'vsc@bpsd9.org', 160 - 40 * 2)
          contact_box('Membership', 'Membership', 'membership@bpsd9.org', 160 - 40 * 3)
        end

        def contact_box(name, committee, email, y_pos)
          chair_name = Committee.find_by(name: committee)&.user&.full_name(html: false) || 'TBD'
          return unless chair_name.present?

          contact_box_committee(name, chair_name, y_pos)
          contact_box_email(email, y_pos)
        end

        def contact_box_committee(name, chair_name, y_pos)
          bounding_box([0, y_pos], width: 175, height: 40) do
            formatted_text(
              [{ text: "#{name}\n", styles: [:bold] }, { text: chair_name }],
              size: BpsPdf::Roster::Detailed::HEADING_SIZE, align: :left, valign: :center
            )
          end
        end

        def contact_box_email(email, y_pos)
          bounding_box([175, y_pos], width: 150, height: 40) do
            formatted_text(
              [{ text: email }],
              size: BpsPdf::Roster::Detailed::HEADING_SIZE, align: :center, valign: :center
            )
          end
        end
      end
    end
  end
end
