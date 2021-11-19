# frozen_string_literal: true

module BPS
  module PDF
    class Roster
      class Detailed
        module Benefits
          def benefits
            formatted_page do
              benefits_intro
              benefits_list
              store_info
              benefits_disclaimer
            end
          end

        private

          def benefits_intro
            intro_block('Member Benefits', config_text[:benefits][:top], 60)
          end

          def benefits_list
            link_groups = config_text[:benefits][:links]
            return unless link_groups.size.positive?

            left, right = split_link_groups(link_groups)

            bounding_box([0, 480], width: 150, height: 400) do
              display_link_groups(left)
            end

            bounding_box([175, 480], width: 150, height: 400) do
              display_link_groups(right)
            end
          end

          def split_link_groups(link_groups)
            left = link_groups.slice(:'Advancing Education', :'Marine Benefits', :'Travel Benefits')
            right = link_groups.slice(
              :'Goods and Services', :'Insurance Benefits', :'Health Benefits', :'USPS Benefits'
            )

            [left, right]
          end

          def display_link_groups(groups)
            groups.each do |category, links|
              body_text "<b>#{category}</b>"
              links.each do |link|
                body_text "– <a href='#{link[:url]}'>#{link[:text]}</a>", align: :left
              end
              body_text '<br>'
            end
          end

          def store_info
            supply_officer = Committee.find_by(department: :treasurer, name: 'Supply')
            supply = supply_officer.present? ? ", #{supply_officer.user.simple_name}, " : ''
            bounding_box([0, 100], width: 325, height: 80) do
              text(
                "Ship's Store",
                size: BPS::PDF::Roster::Detailed::HEADING_SIZE, style: :bold, align: :center
              )
              move_down(10)
              body_text config_text[:benefits][:store].gsub('%supply', supply)
            end
          end

          def benefits_disclaimer
            bounding_box([0, 15], width: 325, height: 15) do
              text(
                config_text[:benefits][:disclaimer],
                size: BPS::PDF::Roster::Detailed::BODY_SM_SIZE, align: :justify
              )
            end
          end
        end
      end
    end
  end
end
