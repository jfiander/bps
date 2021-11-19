# frozen_string_literal: true

module BPS
  module PDF
    class Roster
      class Detailed
        module Directory
          def directory
            users = User.for_roster

            users.each_slice(6) do |page|
              formatted_page do
                directory_page(page)
              end
            end
          end

        private

          def directory_page(users)
            users.each_with_index do |user, index|
              roster_entry(user, y_offset: 90 * index)
            end
          end
        end
      end
    end
  end
end
