# frozen_string_literal: true

module User::RosterFormat
  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods
    def for_roster
      alphabetized.unlocked.include_positions.map do |u|
        {
          left: left(u).compact,
          middle: middle(u).compact,
          right: right(u).compact
        }
      end
    end

    private

    def left(u)
      [
        u.full_name(html: false),
        allow_blank(u.spouse_name),
        allow_blank(prefix(u.phone_h, 'h.')),
        allow_blank(u.address_1),
        u.address_2,
        allow_blank(city_state(u)),
        allow_blank(u.zip),
        allow_blank(u.email)
      ]
    end

    def middle(u)
      [
        allow_blank(u.certificate),
        allow_blank(postfix(u.total_years, 'years')),
        allow_blank(prefix(u.phone_c, 'c.')),
        allow_blank(postfix(u.mm, 'Merit Marks')),
        allow_blank(member_level(u)),
        allow_blank(prefix(u.fax, 'f.'))
      ]
    end

    def right(u)
      [
        allow_blank(u.home_port),
        allow_blank(u.birthday),
        allow_blank(prefix(u.phone_w, 'w.')),
        allow_blank(u.boat_name),
        allow_blank(u.boat_type),
        allow_blank(u.mmsi),
        allow_blank(u.call_sign)
      ]
    end

    def allow_blank(field)
      field || ' '
    end

    def city_state(u)
      return nil unless u.city.present? && u.state.present?
      "#{u.city}, #{u.state}"
    end

    def member_level(u)
      return 'Emeritus Member' if u.mm.to_i >= 50
      return 'Life Member' if u.life
      return 'Senior Member' if u.senior
    end

    def prefix(string, pre)
      string.present? ? "#{pre} #{string}" : nil
    end

    def postfix(string, post)
      string.present? ? "#{string} #{post}" : nil
    end
  end
end
