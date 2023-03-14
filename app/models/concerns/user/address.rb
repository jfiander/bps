# frozen_string_literal: true

class User
  module Address
    extend ActiveSupport::Concern

    def mailing_address(name: true)
      [
        (name ? full_name(html: false) : nil),
        address_1,
        address_2,
        "#{city} #{state} #{zip}"
      ].compact_blank
    end

    def geo_address
      addr = [address_1, city, state].join(', ')
      addr.match?(/Canada/i) ? addr : "#{addr}, USA"
    end

    def lat_lon(human: true)
      coordinates = Geocoder.search(geo_address).first&.coordinates
      return if coordinates.blank?
      return coordinates unless human

      lat = format_coordinate(coordinates[0], hemi: :ns)
      lon = format_coordinate(coordinates[1], hemi: :ew)

      "#{lat}\t#{lon}"
    end

  private

    def format_coordinate(raw, hemi: :ns)
      deg = raw.abs.floor
      dec = raw.abs - deg
      min = (dec * 60).round(5)

      "#{deg}° #{min}′ #{hemi_flag(raw, hemi)}"
    end

    def hemi_flag(raw, hemi)
      {
        ns: { true => 'S', false => 'N' },
        ew: { true => 'W', false => 'E' }
      }[hemi][raw.negative?]
    end
  end
end
