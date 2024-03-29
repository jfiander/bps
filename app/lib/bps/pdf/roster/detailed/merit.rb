# frozen_string_literal: true

module BPS
  module PDF
    class Roster
      class Detailed
        module Merit
          def merit
            @users = User.alphabetized.unlocked
            load_life_member
            merit_first_page
            merit_second_page
          end

        private

          def merit_first_page
            formatted_page do
              merit_intro
              emeritus
              life
            end
          end

          def merit_second_page
            formatted_page do
              senior
              merit_marks
            end
          end

          def merit_intro
            intro_block('We Honor Our Members', config_text[:merit][:top], 55)
          end

          def emeritus
            emeriti = @users.where('mm >= ?', 50)
            @emeritus_height = (50 + (emeriti.count * 6) + (emeriti.present? ? 10 : 0))
            bounding_box([0, 470], width: 325, height: @emeritus_height) do
              member_collection('Emeritus Members', emeriti, :emeritus, honor: true)
            end
          end

          def life
            life_members = @users.where('mm >= ?', 25).where('mm < ?', 50)
            @life_height = (50 + (life_members.count * 6) + (life_members.present? ? 10 : 0))
            bounding_box([0, 450 - @emeritus_height], width: 325, height: @life_height) do
              member_collection('Life Members', life_members, :life, honor: true)
            end

            life_svg = USPSFlags::Grades.new(membership: :life, outfile: '').svg
            svg life_svg, width: 1325, at: [0, cursor]
          end

          def senior
            senior_members = @users.where('mm >= ?', 5).where('mm < ?', 25)
            @senior_height = (50 + (senior_members.count * 6) + (senior_members.present? ? 10 : 0))
            bounding_box([0, 540], width: 325, height: @senior_height) do
              member_collection('Senior Members', senior_members, :senior)
            end
          end

          def merit_marks
            recent_mms = @users.recent_mm
            @mm_height = (50 + (recent_mms.count * 6) + (recent_mms.present? ? 10 : 0))
            bounding_box([0, 540 - @senior_height], width: 325, height: @mm_height) do
              member_collection('Merit Marks', recent_mms, :merit_marks, mm: true)
            end
          end

          def member_collection(title, collection, description_key, honor: false, mm: false)
            text(
              title,
              size: BPS::PDF::Roster::Detailed::SECTION_TITLE_SIZE, style: :bold, align: :center
            )
            move_down(10)
            text(
              config_text[:merit][description_key],
              size: BPS::PDF::Roster::Detailed::BODY_REG_SIZE, align: :justify
            )
            collection_body(title, collection, honor, mm) if collection.count.positive?
          end

          def collection_body(title, collection, honor, mm)
            move_down(10)
            statement(title, collection, honor) unless mm
            collection.each_slice(2) do |left, right|
              collection_row(left, right)
            end
          end

          def statement(title, collection, honor)
            adj = honor ? 'honored' : 'proud'
            text(
              "We are #{adj} to have #{collection.count} #{title}:",
              size: BPS::PDF::Roster::Detailed::BODY_REG_SIZE, align: :justify
            )
            move_down(10)
          end

          def collection_row(left, right)
            size = BPS::PDF::Roster::Detailed::BODY_REG_SIZE
            draw_text left&.simple_name, size: size, at: [20, cursor]
            draw_text right&.simple_name, size: size, at: [195, cursor]
            move_down(10)
          end

          def load_life_member
            insignia = BPS::S3.new(:static).download('insignia/PNG/membership/tr/life.png')
            File.write('tmp/run/Life.png', insignia)
          end
        end
      end
    end
  end
end
